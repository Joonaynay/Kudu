//
//  FirebaseModel.swift
//  Kudu
//
//  Created by Forrest Buhler on 10/14/21.
//

import UIKit
import FirebaseFirestore
import AlgoliaSearchClient
import CoreMIDI

class FirebaseModel: ObservableObject {
    
    static let shared = FirebaseModel()
    
    public let file = FileManagerModel.shared
    public let storage = StorageModel.shared
    private let cd = Persistence()
    public let db = FirestoreModel.shared
    
    @Published public var currentUser = User(id: "", username: "", name: "", likes: [], profileImage: nil, following: [], followers: [], posts: [])
    @Published public var users = [User]()
    @Published public var posts = [Post]()
    @Published public var subjects = [Subject]()
    public let algoliaClient: SearchClient
    public let algoliaIndex: Index
    
    init() {
        self.algoliaClient = SearchClient(appID: "Y9I3DGQAIY", apiKey: "f2c8c8deff57a9f6c1471ceaccf3dcef")
        self.algoliaIndex = algoliaClient.index(withName: "title")
        
        self.subjects = [Subject(name: "Quotes", image: "quote.bubble"), Subject(name: "Entrepreneurship", image: "person"), Subject(name: "Career", image: "building.2"), Subject(name: "Workout", image: "heart"), Subject(name: "Confidence", image: "crown"), Subject(name: "Communication", image: "bubble.left"), Subject(name: "Motivation", image: "lightbulb"), Subject(name: "Spirituality", image: "leaf"), Subject(name: "Financial", image: "dollarsign.square"), Subject(name: "Focus", image: "scope"), Subject(name: "Happiness", image: "face.smiling"), Subject(name: "Habits", image: "infinity"), Subject(name: "Success", image: "hands.sparkles"), Subject(name: "Books/Audiobooks", image: "book"), Subject(name: "Failure", image: "cloud.heavyrain"), Subject(name: "Leadership", image: "person.3"), Subject(name: "Relationships", image: "figure.wave"), Subject(name: "Will Power", image: "bolt.circle"), Subject(name: "Mindfulness", image: "rays"), Subject(name: "Purpose", image: "sunrise"), Subject(name: "Time Management", image: "clock"), Subject(name: "Goals", image: "target")].sorted { $0.name < $1.name }
    }
    
    
    
    func likePost(post: Int) {
        
        if !self.currentUser.likes.contains(self.posts[post].id) {
            //Save the users current ID to the likes on the post, so we can later get the number of people who have liked the post.
            Firestore.firestore().collection("users").document(self.currentUser.id).updateData(["likes": FieldValue.arrayUnion([self.posts[post].id])])
            Firestore.firestore().collection("posts").document(self.posts[post].id).updateData(["likeCount": FieldValue.increment(Int64(1))])
            self.posts[post].likeCount += 1
            self.currentUser.likes.append(self.posts[post].id)
            if let index = self.users.firstIndex(where: { users in users.id == self.currentUser.id }) {
                self.users[index].likes.append(self.posts[post].id)
            }            
            
            //Save to coredata
            let coreUser = cd.fetchUser(uid: self.currentUser.id)
            coreUser?.likes?.append(self.posts[post].id)
            cd.save()
        } else {
            Firestore.firestore().collection("users").document(self.currentUser.id).updateData(["likes": FieldValue.arrayRemove([self.posts[post].id])])
            Firestore.firestore().collection("posts").document(self.posts[post].id).updateData(["likeCount": FieldValue.increment(Int64(-1))])
            self.currentUser.likes.removeAll() { like in like == self.posts[post].id }
            if let index = self.users.firstIndex(where: { users in users.id == self.currentUser.id }) {
                self.users[index].likes.removeAll() { like in like == self.posts[post].id }
            }
            
            self.posts[post].likeCount -= 1
            
            //Save to coredata
            let coreUser = cd.fetchUser(uid: self.currentUser.id)
            coreUser?.likes?.removeAll(where: { like in like == self.posts[post].id })
            cd.save()
        }
    }
    
    
    func commentOnPost(currentPost: Post, comment: String, completion: @escaping () -> Void) {
        
        //Save comments when someone comments on a post
        self.saveDeepCollection(collection: "posts", collection2: "comments", document: currentPost.id, document2: currentUser.id, field: "comments", data: [comment]) {
            completion()
        }
    }
    
    func loadComments(currentPost: Post, completion:@escaping ([Comment]?) -> Void) {
        self.getDocsDeep(collection: "posts", document: currentPost.id, collection2: "comments") { [weak self] userDocs in
            guard let self = self else { return }
            
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
                    if list.isEmpty {
                        completion(nil)
                    } else {
                        completion(list)
                    }
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
    
    func saveDeepCollection(collection: String, collection2: String, document: String, document2: String, field: String, data: Any, completion:@escaping () -> Void) {
        
        let document = Firestore.firestore().collection(collection).document(document).collection(collection2).document(document2)
        
        document.getDocument { doc, error in
            if doc != nil && error == nil {
                // Check if data is an array
                if let array = data as? [String] {
                    //Append data in firestore
                    if doc?.get("comments") != nil {
                        document.updateData([field: FieldValue.arrayUnion(array)])
                        completion()
                    } else {
                        document.setData([field: data])
                        completion()
                    }
                    
                    
                    // Check if data is a string
                } else if let string = data as? String {
                    //Save data in firestore
                    document.setValue(string, forKey: field)
                    
                    completion()
                }
            } else {
                completion()
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
            if let index = self.users.firstIndex(where: { users in users.id == followUser.id }) {
                self.users[index].followers.append(self.currentUser.id)
            }
            
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
            if let index = self.users.firstIndex(where: { users in users.id == followUser.id }) {
                self.users[index].followers.removeAll { follower in
                    follower == self.currentUser.id
                }
            }
            
            //Save to core data
            let deleteCoreUser = cd.fetchUser(uid: currentUser.id)
            if let newIndex = deleteCoreUser?.following?.firstIndex(of: followUser.id) {
                deleteCoreUser?.following?.remove(at: newIndex)
            }
            cd.save()
            
            completion()
            
        }
        
    }
    
    
    func loadPost(postId: String, completion:@escaping () -> Void) {
        
        if self.posts.contains(where: { post in
            post.id == postId
        }) {
            completion()
        } else {
            
            //Load Post Firestore Document
            self.db.getDoc(collection: "posts", id: postId) { [weak self] document in
                guard let self = self else { return }
                
                
                if let doc = document {
                    guard let title = doc.get("title") as? String else {
                        completion()
                        return
                    }
                    let postId = doc.documentID
                    guard let subjects = doc.get("subjects") as? [String] else {
                        completion()
                        return
                    }
                    guard let time = doc.get("date") as? TimeInterval else {
                        completion()
                        return
                    }
                    guard let uid = doc.get("uid") as? String else {
                        completion()
                        return
                    }
                    guard let description = doc.get("description") as? String else {
                        completion()
                        return
                    }
                    guard let likeCount = doc.get("likeCount") as? Int else {
                        completion()
                        return
                    }
                    
                    //Load user for post
                    self.loadConservativeUser(uid: uid) { user in
                        
                        //Load image
                        self.storage.loadImage(path: "images", id: doc.documentID) { image in
                            
                            //Load Movie
                            self.storage.loadMovie(path: "videos", file: "\(doc.documentID).m4v") { url in
                                //Add to view model
                                
                                if let image = image, let user = user {
                                    let post = (Post(id: postId, image: image, title: title, subjects: subjects, date: Date(timeIntervalSince1970: time), uid: user.id, likeCount: likeCount, movie: url, description: description))   
                                    self.posts.append(post)
                                    completion()
                                } else {
                                    completion()
                                }
                            }
                        }
                    }
                } else {
                    completion()
                }
            }
        }
    }
    
    
    func loadUser(uid: String, completion:@escaping (User?) -> Void) {
        if let user = self.users.first(where: { users in
            users.id == uid
        }) {
            print("Loaded User From Model")
            completion(user)
        } else {
            
            //Load Firestore doc
            db.getDoc(collection: "users", id: uid) { [weak self] doc in
                guard let self = self else { return }

                guard let doc = doc else {
                    completion(nil)
                    return
                }
                                                                
                guard let username = doc.get("username") as? String else {
                    completion(nil)
                    return
                }
                guard let name = doc.get("name") as? String else {
                    completion(nil)
                    return
                }
                guard let following = doc.get("following") as? [String] else {
                    completion(nil)
                    return
                }
                guard let followers = doc.get("followers") as? [String] else {
                    completion(nil)
                    return
                }
                guard let posts = doc.get("posts") as? [String] else {
                    completion(nil)
                    return
                }
                guard let likes = doc.get("likes") as? [String] else {
                    completion(nil)
                    return 
                }
                
                //Load Profile Image
                self.storage.loadImage(path: "Profile Images", id: uid) { profileImage in
                    
                    //Create User
                    let user = User(id: uid, username: username, name: name, likes: likes, profileImage: profileImage, following: following, followers: followers, posts: posts)
                    print("Loaded User From Firebase")
                    if !self.users.contains(where: { users in
                        user.id == users.id
                    }) {
                        self.users.append(user)
                    }
                    
                    //Return User
                    completion(user)
                }
            }
        }
    }
    
    func addPost(image: UIImage, title: String, subjects: [String], movie: URL?, description: String?) {
        
        // Make sure they have a description
        var desc = ""
        if description != nil {
            desc = description!
        }
        
        let date = Date().timeIntervalSince1970
        //Save Post to Firestore
        let dict = ["title": title, "subjects": subjects, "uid": self.currentUser.id, "date": date, "description": desc, "likeCount": 0] as [String : Any]
        self.db.newDoc(collection: "posts", document: nil, data: dict) { [weak self] postId in
            guard let self = self else { return }
            
            //Save postId to User
            self.db.save(collection: "users", document: self.currentUser.id, field: "posts", data: [postId!])
            
            //Save to filemanager
            self.file.saveImage(image: image, id: postId!)
            
            //Save Image to Firebase Storage
            self.storage.saveImage(path: "images", file: postId!, image: image)
            
            //Save movie to Firestore
            if let movie = movie {
                self.storage.saveMovie(path: "videos", file: postId!, url: movie)
            }
            
            //Save to core data
            if let current = self.cd.fetchUser(uid: self.currentUser.id) {
                current.posts?.append(postId!)
            }
            
            //Save to algolia
            let records = ["objectID": postId, "title": title]
            do {
                try self.algoliaIndex.saveObject(records)
            } catch let error { print(error.localizedDescription) }
        }
    }
    
    
    func deletePost(id: String) {
        //Remove from user document in firestore
        Firestore.firestore().collection("users").document(self.currentUser.id).updateData(["posts": FieldValue.arrayRemove([id])])
        
        //Remove from Current user
        self.currentUser.posts.removeAll { string in string == id }
        if let index = self.users.firstIndex(where: { user in user.id == self.currentUser.id }) {
            self.users[index].posts.removeAll(where: { string in string == id })
        }
        let coreUser = self.cd.fetchUser(uid: self.currentUser.id)
        coreUser?.posts?.removeAll(where: { string in string == id })
        self.cd.save()
        
        //Delete document and comments
        self.db.deleteDoc(collection: "posts", document: id)
        let commentsDb = Firestore.firestore().collection("posts").document(id).collection("comments")
        commentsDb.getDocuments { query, error in
            if let query = query {
                for doc in query.documents {
                    commentsDb.document(doc.documentID).delete()
                }
            }
        }
        
        //Delete File
        self.storage.delete(path: "images", file: id)
        self.storage.delete(path: "videos", file: "\(id).m4v")
        
        //Remove from algolia
        do {
            try self.algoliaIndex.deleteObject(withID: ObjectID(stringLiteral: id))
        } catch let error { fatalError(error.localizedDescription) }
        
        //Remove from FirebaseModel
        self.posts.removeAll { post in post.id == id }
        
    }
    

    
    func loadConservativeUser(uid: String, completion:@escaping (User?) -> Void) {
        
        if let user = self.users.first(where: { users in users.id == uid }) {
            print("Loaded User From Model")
            completion(user)
        } else {
            
            //Load Firestore doc
            self.db.getDoc(collection: "users", id: uid) { doc in
                
                print("Loaded User From Firebase")
                
                guard let username = doc?.get("username") as? String else { return }
                
                //Load Profile Image
                self.storage.loadImage(path: "Profile Images", id: uid) { [weak self] profileImage in
                    guard let self = self else { return }
                    
                    //Create User
                    let user = User(id: uid, username: username, name: nil, likes: [], profileImage: profileImage, following: [], followers: [], posts: [])
                    self.users.append(user)
                    
                    //Return User
                    completion(self.users.last)
                }
            }            
        }
    }
}



