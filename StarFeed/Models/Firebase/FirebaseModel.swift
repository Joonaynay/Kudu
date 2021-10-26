//
//  FirebaseModel.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/14/21.
//

import UIKit
import FirebaseFirestore

class FirebaseModel: ObservableObject {
    
    static let shared = FirebaseModel()
    
    private let file = FileManagerModel.shared
    private let storage = StorageModel.shared
    private let cd = Persistence()
    private let db = FirestoreModel.shared
    
    @Published public var currentUser = User(id: "", username: "", name: "", profileImage: nil, following: [], followers: [], posts: [])
    @Published public var users = [User]()
    @Published public var posts = [PostView]()

    
    @Published public var subjects = [Subject]()
    
    init() {
        self.subjects = [Subject(name: "Business", image: "building.2"), Subject(name: "Workout", image: "heart")]
    }
    
    func likePost(currentPost: Post) {
        
        if !currentPost.likes.contains(currentUser.id) {
            //Save the users current ID to the likes on the post, so we can later get the number of people who have liked the post.
            db.save(collection: "posts", document: currentPost.id, field: "likes", data: [self.currentUser.id])
        } else {
            Firestore.firestore().collection("posts").document(currentPost.id).updateData(["likes": FieldValue.arrayRemove([currentUser.id])])
        }
    }
    
    func commentOnPost(currentPost: Post, comment: String) {
        
        //Save comments when someone comments on a post
        self.saveDeepCollection(collection: "posts", collection2: "comments", document: currentPost.id, document2: currentUser.id, field: "comments", data: [comment])
        
    }
    
    func loadComments(currentPost: Post, completion:@escaping ([Comment]?) -> Void) {
        self.getDocsDeep(collection: "posts", document: currentPost.id, collection2: "comments") { userDocs in
            
            if let userDocs = userDocs {
                var list: [Comment] = []
                
                if !userDocs.documents.isEmpty {
                    completion(nil)
                }
                let group = DispatchGroup()
                for doc in userDocs.documents {
                    group.enter()
                    self.loadConservativeUser(uid: doc.documentID) { user in
                        let comments = doc.get("comments") as! [String]
                        if let user = user {
                            for comment in comments {
                                list.append(Comment(text: comment, user: user))
                            }
                            group.leave()
                        } else {
                            group.leave()
                        }
                    }
                }
                group.notify(queue: .main) {
                    completion(list)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func getDocsDeep(collection: String, document: String, collection2: String, completion:@escaping (QuerySnapshot?) -> Void) {
        //Load Documents
        Firestore.firestore().collection(collection).document(document).collection(collection2).getDocuments { docs, error in
            
            //Check for error
            if error == nil {
                
                //Return documents
                completion(docs)
            } else {
                completion(nil)
            }
        }
    }
    
    func saveDeepCollection(collection: String, collection2: String, document: String, document2: String, field: String, data: Any) {
        
        let document = Firestore.firestore().collection(collection).document(document).collection(collection2).document(document2)
        
        document.getDocument { doc, error in
            if doc != nil && error == nil {
                // Check if data is an array
                if let array = data as? [String] {
                    //Append data in firestore
                    if doc?.get("comments") != nil {
                        print("ooga booga")
                        document.updateData([field: FieldValue.arrayUnion(array)])
                    } else {
                        document.setData([field: data])
                    }
                    
                    
                // Check if data is a string
                } else if let string = data as? String {
                    //Save data in firestore
                    document.setValue(string, forKey: field)
                }
            }
        }
    }
    
    func followUser(followUser: User, completion:@escaping () -> Void) {
        if !currentUser.following.contains(followUser.id) {
            //Follow the user
            
            //Save who the user followed
            db.save(collection: "users", document: currentUser.id, field: "following", data: [followUser.id])
            
            //Save that the followed user got followed
            db.save(collection: "users", document: followUser.id, field: "followers", data: [currentUser.id])
            
            //Add to UserModel            
            self.currentUser.following.append(followUser.id)
            
            //Save to core data
            let coreUser = cd.fetchUser(uid: currentUser.id)
            coreUser?.following?.append(followUser.id)
            cd.save()
            
            completion()
            
        } else {
            // Unfollow user
            Firestore.firestore().collection("users").document(followUser.id).updateData(["followers": FieldValue.arrayRemove([currentUser.id])])
            Firestore.firestore().collection("users").document(currentUser.id).updateData(["following": FieldValue.arrayRemove([followUser.id])])
            
            // Delete from UserModel
            let index = currentUser.following.firstIndex(of: followUser.id)
            currentUser.following.remove(at: index!)
            
            //Save to core data
            let deleteCoreUser = cd.fetchUser(uid: currentUser.id)
            let newIndex = deleteCoreUser?.following?.firstIndex(of: followUser.id)
            deleteCoreUser?.following?.remove(at: newIndex!)
            cd.save()
            
            completion()
            
        }
        
    }
    
    func search(string: String, completion:@escaping () -> Void) {
        
        DispatchQueue.main.async {

            let group = DispatchGroup()
            //Load all documents
            self.db.getDocs(collection: "posts") { query in
                
                var postsArray = [PostView]()
                
                for doc in query!.documents {
                    
                    group.enter()
                    var postId = ""
                    let title = doc.get("title") as! String
                    if title.lowercased().contains(string.lowercased()) {
                        postId = doc.documentID
                    }
                    
                    self.loadPost(postId: postId, completion: { post in
                        if let p = post {
                            let pview = PostView(post: p)
                            postsArray.append(pview)
                        }
                        
                        
                        group.leave()
                    })
                }
                
                group.notify(queue: .main, execute: {
                    for post in postsArray {
                        if !self.posts.contains(where: { pview in
                            pview.post.id == post.post.id }) {
                            self.posts.append(post)
                        }
                    }
                    completion()
                })
            }
        }
    }
    
    func loadPost(postId: String, completion:@escaping (Post?) -> Void) {
        
        //Load Post Firestore Document
        self.db.getDoc(collection: "posts", id: postId) { document in
            
            
            if let doc = document {
                //Check if local loaded posts is equal to firebase docs
                //Loop through each document and get data
                let title = doc.get("title") as! String
                let postId = doc.documentID
                let subjects = doc.get("subjects") as! [String]
                let date = doc.get("date") as! String
                let uid = doc.get("uid") as! String
                let likes = doc.get("likes") as! [String]
                
                //Load user for post
                self.loadConservativeUser(uid: uid) { user in
                    
                    //Load image
                    self.storage.loadImage(path: "images", id: doc.documentID) { image in
                        
                        //Load Movie
                        self.storage.loadMovie(path: "videos", file: "\(doc.documentID).m4v") { url in
                            //Add to view model
                            
                            if let image = image, let url = url {
                                let post = (Post(id: postId, image: image, title: title, subjects: subjects, date: date, user: user!, likes: likes, movie: url))
                                completion(post)
                            } else {
                                completion(nil)
                            }
                        }
                    }
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func loadPosts(completion:@escaping () -> Void) {
                
        //Load all Post Firestore Documents
        self.db.getDocs(collection: "posts") { query in
            
            //Check if local loaded posts is equal to firebase docs
            if self.posts.count != query?.count {
                
                let group = DispatchGroup()
                //Loop through each document and get data
                var posts = [PostView]()
                for post in query!.documents {
                    group.enter()
                    let title = post.get("title") as! String
                    let postId = post.documentID
                    let subjects = post.get("subjects") as! [String]
                    let date = post.get("date") as! String
                    let uid = post.get("uid") as! String
                    let likes = post.get("likes") as! [String]
                    
                    //Load user for post
                    self.loadConservativeUser(uid: uid) { user in
                        
                        //Load image
                        self.storage.loadImage(path: "images", id: post.documentID) { image in
                            
                            //Load Movie
                            self.storage.loadMovie(path: "videos", file: "\(post.documentID).m4v") { url in
                                //Add to view model
                                
                                if let image = image, let url = url {
                                    let post = (Post(id: postId, image: image, title: title, subjects: subjects, date: date, user: user!, likes: likes, movie: url))
                                    posts.append(PostView(post: post))
                                }
                                group.leave()
                            }
                        }
                    }
                }
                group.notify(queue: .main) {
                    self.posts = posts
                    completion()
                }
            } else {
                completion()
            }
        }
    }
    
    func loadUser(uid: String, completion:@escaping (User?) -> Void) {
        
        //Check if can load from Core Data
        if let user = cd.fetchUser(uid: uid) {
            print("Loaded User From Core Data")
            
            if let profileImage = self.file.getFromFileManager(name: uid) {
                completion(User(id: user.id!, username: user.username!, name: user.name!, profileImage: profileImage, following: user.following!, followers: user.followers! ,posts: user.posts!))
            } else {
                completion(User(id: user.id!, username: user.username!, name: user.name!, profileImage: nil, following: user.following!, followers: user.followers! ,posts: user.posts!))
            }
            
        } else {
            
            //Load Firestore doc
            db.getDoc(collection: "users", id: uid) { doc in
                
                print("Loaded User From Firebase")
                
                
                let username = doc?.get("username") as! String
                let name = doc?.get("name") as! String
                let following = doc?.get("following") as! [String]
                let followers = doc?.get("followers") as! [String]
                let posts = doc?.get("posts") as! [String]
                
                //Load Profile Image
                self.storage.loadImage(path: "Profile Images", id: uid) { profileImage in

                    //Create User
                    let user = User(id: uid, username: username, name: name, profileImage: profileImage, following: following, followers: followers, posts: posts)
                    self.users.append(user)
                    
                    //Return User
                    completion(user)
                }
            }
        }
    }
    
    func addPost(image: UIImage, title: String, subjects: [String], movie: URL) {
        
        //Find Date
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .long
        dateFormat.timeStyle = .none
        let dateString = dateFormat.string(from: Date())
        
        //Save Post to Firestore
        let dict = ["title": title, "subjects": subjects, "uid": self.currentUser.id, "date": dateString, "likes": []] as [String : Any]
        self.db.newDoc(collection: "posts", document: nil, data: dict) { postId in
            
            //Save postId to User
            self.db.save(collection: "users", document: self.currentUser.id, field: "posts", data: [postId!])
            
            //Save to filemanager
            self.file.saveImage(image: image, name: postId!)
            
            //Save Image to Firebase Storage
            self.storage.saveImage(path: "images", file: postId!, image: image)
            
            //Save movie to Firestore
            self.storage.saveMovie(path: "videos", file: postId!, url: movie)
            
            //Save to core data
            if let current = self.cd.fetchUser(uid: self.currentUser.id) {
                current.posts?.append(postId!)
            }
        }
    }
    
    func loadConservativeUser(uid: String, completion:@escaping (User?) -> Void) {
        
        //Check if can load from Core Data
        if let user = cd.fetchUser(uid: uid) {
        
            print("Loaded User From Core Data")
            
            
            if let profileImage = self.file.getFromFileManager(name: uid) {
                completion(User(id: user.id!, username: user.username!, name: user.name!, profileImage: profileImage, following: user.following!, followers: user.followers!, posts: []))
            } else {
                completion(User(id: user.id!, username: user.username!, name: user.name!, profileImage: nil, following: user.following!, followers: user.followers!, posts: []))
            }
            
        } else {
            
            //Load Firestore doc
            self.db.getDoc(collection: "users", id: uid) { doc in
                                
                print("Loaded User From Firebase")
                
                let username = doc?.get("username") as! String
                
                //Load Profile Image
                self.storage.loadImage(path: "Profile Images", id: uid) { profileImage in
                    
                    
                    //Create User
                    let user = User(id: uid, username: username, name: nil, profileImage: profileImage, following: [], followers: [], posts: [])
                    self.users.append(user)
                    
                    //Return User
                    completion(user)
                }
            }
        }
    }
}


