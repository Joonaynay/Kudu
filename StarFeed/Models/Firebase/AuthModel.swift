//
//  AuthModel.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/13/21.
//

import UIKit
import FirebaseAuth
import CoreData

class AuthModel: ObservableObject {
    static let shared = AuthModel()
    
    private let auth = Auth.auth()
    
    private let file = FileManagerModel()
    private lazy var storage = StorageModel()
    private lazy var cd = Persistence()
    private lazy var db = FirestoreModel.shared
    
    public var currentUser = User(id: "", username: "", name: "", profileImage: nil, following: [], followers: [], posts: nil)
    public var users = [User]()
    
    
    @Published public var signedIn = false
    
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
    
    func checkEmail(completion:@escaping (String?) -> Void) {
        auth.currentUser?.reload(completion: { error in
            if error == nil {
                if self.auth.currentUser?.isEmailVerified == true {
                    completion(nil)
                } else {
                    completion("Email not verified")
                }
            } else {
                completion(error?.localizedDescription)
            }
        })
    }
    
    func changeEmail(email: String, completion:@escaping (String?) -> Void) {
        auth.currentUser?.updateEmail(to: email, completion: { error in
            if let error = error  {
                completion(error.localizedDescription)
            } else {
                completion(nil)
            }
            
        })
    }
    
    
    func signIn(email: String, password: String, completion:@escaping (String?) -> Void) {
        
        self.auth.signIn(withEmail: email, password: password) { result, error in
            if result != nil && error == nil {
                
                //Save uid to userdefaults
                UserDefaults.standard.setValue(self.auth.currentUser?.uid, forKeyPath: "uid")
                
                self.loadUser(uid: self.auth.currentUser!.uid) { user in
                    if let user = user {
                        self.currentUser = user
                        
                        //Save to Core Data
                        let currentUser = CurrentUser(context: self.cd.context)
                        currentUser.username = user.username
                        currentUser.id = self.auth.currentUser?.uid
                        currentUser.name = user.name
                        currentUser.followers = user.followers
                        currentUser.following = user.following
                        self.cd.save()
                        
                        //Save ProfileImage to FileManager
                        if let profileImage = user.profileImage {
                            self.file.saveImage(image: profileImage, name: user.id)
                        }
                        
                        completion(nil)
                        
                    } else {
                        completion("Error")
                    }
                    
                }
            } else if let error = error {
                completion(error.localizedDescription)
            }
        }
    }
    
    func signUp(email: String, password: String, confirm: String, name: String, username: String, completion:@escaping (String?) -> Void) {
        
        if name.count < 45 {
            if username.count < 20 {
                if confirm == password {
                    
                    db.getDocs(collection: "users") { query in
                        let group = DispatchGroup()
                        for doc in query!.documents {
                            group.enter()
                            let otherUsername = doc.get("username") as! String
                            if otherUsername == username {
                                group.leave()
                                completion("That username is already taken.")
                                break
                            } else {
                                group.leave()
                            }
                        }
                        
                        group.notify(queue: .main) {
                            //Create User
                            self.auth.createUser(withEmail: email, password: password) { [self] result, error in
                                
                                //Check for success
                                if result != nil && error == nil {
                                    
                                    //Save to Core Data
                                    let currentUser = CurrentUser(context: self.cd.context)
                                    currentUser.username = username
                                    currentUser.id = self.auth.currentUser?.uid
                                    currentUser.name = name
                                    currentUser.followers = []
                                    currentUser.following = []
                                    self.cd.save()
                                    
                                    //Save uid to userdefaults
                                    UserDefaults.standard.setValue(self.auth.currentUser?.uid, forKeyPath: "uid")
                                    
                                    
                                    // Save data in Firestore
                                    let dict = ["name": name, "username": username, "posts": [], "followers": [], "following": []] as [String : Any]
                                    db.newDoc(collection: "users", document: self.auth.currentUser?.uid, data: dict) { uid in }
                                    
                                    //Send Email Verification
                                    self.auth.currentUser!.sendEmailVerification(completion: { error in
                                        if error != nil {
                                            completion(error?.localizedDescription)
                                        } else {
                                            self.loadUser(uid: self.auth.currentUser!.uid) { user in
                                                self.currentUser = user!
                                            }
                                            completion(nil)
                                        }
                                    })
                                    
                                } else {
                                    // Return Error
                                    completion(error?.localizedDescription)
                                }
                            }
                        }
                    }
                } else {
                    completion("Password and confirm password do not match.")
                }
            } else {
                completion("Username must be less than 20 characters.")
            }
        } else {
            completion("First and last name must be less than 45 characters.")
        }
    }
    
    func signOut() {
        UserDefaults.standard.setValue(nil, forKeyPath: "uid")
        self.file.deleteAllImages()
        self.cd.deleteAll()
        self.cd.container = NSPersistentContainer(name: "FreshModel")
        self.cd.container.loadPersistentStores { desc, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
        self.cd.context = self.cd.container.viewContext
        do {
            try auth.signOut()
        } catch let error {
            print("Error signing out. \(error)")
        }
        self.signedIn = false
    }
    
    
}

