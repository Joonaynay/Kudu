//
//  FirebaseModel.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/14/21.
//

import UIKit

class FirebaseModel: ObservableObject {
    
    static let shared = FirebaseModel()
    
    private let file = FileManagerModel.shared
    private let storage = StorageModel.shared
    private let cd = Persistence.shared
    private let db = FirestoreModel.shared
    
    @Published public var currentUser = User(id: "", username: "", name: "", profileImage: nil, following: [], followers: [], posts: nil)
    @Published public var users = [User]()
    @Published public var posts = [Post]()
    @Published public var subjects = [Subject]()
    
    
    func loadPosts(completion:@escaping (Bool) -> Void) {
                
        //Load all Post Firestore Documents
        self.db.getDocs(collection: "posts") { query in
            
            //Check if local loaded posts is equal to firebase docs
            if self.posts.count != query?.count {
                
                let group = DispatchGroup()
                //Loop through each document and get data
                var posts = [Post]()
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
                                    posts.append(Post(id: postId, image: image, title: title, subjects: subjects, date: date, user: user!, likes: likes, movie: url))
                                }
                                group.leave()
                            }
                        }
                    }
                }
                group.notify(queue: .main) {
                    self.posts = posts
                    completion(true)
                }
            } else {
                completion(false)
            }
        }
    }
    
    func loadUser(uid: String, completion:@escaping (User?) -> Void) {
        
        //Check if can load from Core Data
        if let user = cd.fetchUser(uid: uid) {
            print("Loaded User From Core Data")
            
            if let profileImage = self.file.getFromFileManager(name: uid) {
                completion(User(id: user.id!, username: user.username!, name: user.name!, profileImage: profileImage, following: user.following!, followers: user.followers! ,posts: nil))
            } else {
                completion(User(id: user.id!, username: user.username!, name: user.name!, profileImage: nil, following: user.following!, followers: user.followers! ,posts: nil))
            }
            
        } else {
            
            //Load Firestore doc
            db.getDoc(collection: "users", id: uid) { doc in
                
                print("Loaded User From Firebase")
                
                
                let username = doc?.get("username") as! String
                let name = doc?.get("name") as! String
                let following = doc?.get("following") as! [String]
                let followers = doc?.get("followers") as! [String]
                
                //Load Profile Image
                self.storage.loadImage(path: "Profile Images", id: uid) { profileImage in
                    
                    //Core Data
                    
                    
                    //Create User
                    let user = User(id: uid, username: username, name: name, profileImage: profileImage, following: following, followers: followers, posts: nil)
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
        }
    }
    
    func loadConservativeUser(uid: String, completion:@escaping (User?) -> Void) {
        
        //Check if can load from Core Data
        if let user = cd.fetchUser(uid: uid) {
        
            print("Loaded User From Core Data")
            
            
            if let profileImage = self.file.getFromFileManager(name: uid) {
                completion(User(id: user.id!, username: user.username!, name: user.name!, profileImage: profileImage, following: user.following!, followers: user.followers!, posts: nil))
            } else {
                completion(User(id: user.id!, username: user.username!, name: user.name!, profileImage: nil, following: user.following!, followers: user.followers!, posts: nil))
            }
            
        } else {
            
            //Load Firestore doc
            self.db.getDoc(collection: "users", id: uid) { doc in
                                
                print("Loaded User From Firebase")
                
                let username = doc?.get("username") as! String
                
                //Load Profile Image
                self.storage.loadImage(path: "Profile Images", id: uid) { profileImage in
                    
                    
                    //Create User
                    let user = User(id: uid, username: username, name: nil, profileImage: profileImage, following: [], followers: [], posts: nil)
                    self.users.append(user)
                    
                    //Return User
                    completion(user)
                }
            }
        }
    }
}


