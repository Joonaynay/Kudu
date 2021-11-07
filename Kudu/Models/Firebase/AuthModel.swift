//
//  AuthModel.swift
//  Kudu
//
//  Created by Forrest Buhler on 10/13/21.
//

import UIKit
import FirebaseAuth
import CoreData
import FirebaseFirestore
import AVFAudio

class AuthModel: ObservableObject {
    static let shared = AuthModel()
    
    private let auth = Auth.auth()
    
    private let file = FileManagerModel.shared
    private let storage = StorageModel.shared
    private lazy var cd = Persistence()
    private let db = FirestoreModel.shared
    private let fb = FirebaseModel.shared
    
    func forgotPassword(email: String, completion: @escaping (String?) -> Void) {
        auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(error.localizedDescription)
            } else {
                completion(nil)
            }
        }
    }
    
    func checkEmail(completion:@escaping (String?) -> Void) {
        auth.currentUser?.reload(completion: { [weak self] error in
            if error == nil {
                if self?.auth.currentUser?.isEmailVerified == true {
                    completion(nil)
                } else {
                    completion("Email not verified")
                }
            } else {
                completion(error?.localizedDescription)
            }
        })
    }
    
    func changeEmail(newEmail: String, completion:@escaping (String?) -> Void) {
        self.auth.currentUser?.updateEmail(to: newEmail, completion: { error in
            if let error = error  {
                completion(error.localizedDescription)
            } else {
                completion(nil)
            }
        })
    }
    
    
    func signIn(email: String, password: String, completion:@escaping (String?) -> Void) {
        
        self.auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }

            if result != nil && error == nil {
                
                //Save uid to userdefaults
                UserDefaults.standard.setValue(self.auth.currentUser?.uid, forKeyPath: "uid")
                
                self.fb.loadUser(uid: self.auth.currentUser!.uid) { user in
                    if let user = user {
                        self.fb.currentUser = user
                        
                        //Save to Core Data
                        let currentUser = CurrentUser(context: self.cd.context)
                        currentUser.username = user.username
                        currentUser.id = self.auth.currentUser?.uid
                        currentUser.name = user.name
                        currentUser.followers = user.followers
                        currentUser.following = user.following
                        currentUser.posts = user.posts
                        currentUser.likes = user.likes
                        self.cd.save()
                        
                        //Save ProfileImage to FileManager
                        if let profileImage = user.profileImage {
                            self.file.saveImage(image: profileImage, id: user.id)
                        }
                        
                        completion(nil)
                        
                    } else {
                        completion("Error")
                    }
                    
                }
            } else if let error = error {
                if error.localizedDescription == "The password is invalid or the user does not have a password." || error.localizedDescription == "There is no user record corresponding to this identifier. The user may have been deleted." {
                    completion("Invalid credentials.")
                } else {
                    completion(error.localizedDescription)
                }
            }
        }
    }
    
    func signUp(email: String, password: String, confirm: String, name: String, username: String, completion:@escaping (String?) -> Void) {
        
        if name.count < 45 {
            if username.count < 20 {
                if confirm == password {
                    
                    db.getDocs(collection: "users") { [weak self] query in
                        guard let self = self else { return }
                        let group = DispatchGroup()
                        for doc in query!.documents {
                            group.enter()
                            let otherUsername = doc.get("username") as! String
                            if otherUsername == username {
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
                                    
                                    //Save uid to userdefaults
                                    UserDefaults.standard.setValue(self.auth.currentUser?.uid, forKeyPath: "uid")
                                    
                                    
                                    // Save data in Firestore
                                    let dict = ["name": name, "username": username, "posts": [], "followers": [], "following": [], "likes": []] as [String : Any]
                                    db.newDoc(collection: "users", document: self.auth.currentUser?.uid, data: dict) { uid in }
                                    
                                    //Send Email Verification
                                    self.auth.currentUser!.sendEmailVerification(completion: { error in
                                        if error != nil {
                                            completion(error?.localizedDescription)
                                        } else {
                                            self.fb.loadUser(uid: self.auth.currentUser!.uid) { user in
                                                if let user = user {
                                                    
                                                    //Save to model
                                                    self.fb.currentUser = user
                                                    
                                                    //Save to coredata
                                                    let currentUser = CurrentUser(context: self.cd.context)
                                                    currentUser.username = user.username
                                                    currentUser.id = self.auth.currentUser?.uid
                                                    currentUser.name = user.name
                                                    currentUser.followers = user.followers
                                                    currentUser.following = user.following
                                                    currentUser.posts = user.posts
                                                    currentUser.likes = user.likes
                                                    self.cd.save()
                                                    
                                                    completion(nil)
                                                }
                                            }
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
    
    func deleteUser(completion:@escaping (String?) -> Void) {
        auth.currentUser!.delete(completion: { [weak self] error in
            guard let self = self else { return }
            if error == nil {
                guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
                self.db.deleteDoc(collection: "users", document: uid)
                self.storage.delete(path: "Profile Images", file: uid)
                for post in self.fb.currentUser.posts {
                    self.fb.deletePost(id: post)
                }
                self.file.deleteAllImages()
                self.cd.deleteAll()
                self.cd.container = NSPersistentContainer(name: "FreshModel")
                self.cd.container.loadPersistentStores { desc, error in
                    if let error = error {
                        fatalError(error.localizedDescription)
                    }
                }
                self.fb.posts = [Post]()
                self.cd.context = self.cd.container.viewContext
                completion(nil)
                UserDefaults.standard.setValue(nil, forKey: "uid")
            } else {
                completion(error?.localizedDescription)
            }
        })
    }
    
    func changePassword(oldPassword: String, newPassword: String, completion: @escaping (String?) -> Void) {
        signIn(email: auth.currentUser!.email!, password: oldPassword) { [weak self] error in
            if error == nil {
                self?.auth.currentUser?.updatePassword(to: newPassword, completion: { error in
                    if error != nil {
                        print(error!.localizedDescription)
                        completion(error!.localizedDescription)
                    }
                })
                completion(nil)
            } else {
                completion(error)
            }
        }
    }
    
    func changeUsername(newUsername: String, completion: @escaping (String?) -> Void) {
        if newUsername.count < 20 {
            Firestore.firestore().collection("users").getDocuments(source: .server) { [weak self] query, error in
                guard let self = self else { return }
                if error != nil {
                    completion("Check your internet connection.")
                } else if let query = query {
                    let group = DispatchGroup()
                    for doc in query.documents {
                        group.enter()
                        guard let otherUsername = doc.get("username") as? String else {
                            completion("Please check your internet connection.")
                            group.leave()
                            return
                        }
                        if otherUsername == newUsername {
                            completion("That username is already taken.")
                            break
                        } else {
                            group.leave()
                        }
                    }
                    group.notify(queue: .main) {
                        completion(nil)
                        self.db.save(collection: "users", document: self.fb.currentUser.id, field: "username", data: newUsername)
                        let coreUser = self.cd.fetchUser(uid: self.fb.currentUser.id)
                        coreUser?.username = newUsername
                        self.cd.save()
                        self.fb.currentUser.username = newUsername
                        if let index = self.fb.users.firstIndex(where: { users in
                            users.id == self.fb.currentUser.id
                        }) {
                            self.fb.users[index].username = newUsername
                        }
                    }
                }
        }
    } else {
        completion("Username must be 20 characters or less.")
    }
}

func signOut(completion:@escaping (String?) -> Void) {
    UserDefaults.standard.setValue(nil, forKeyPath: "uid")
    self.file.deleteAllImages()
    self.cd.deleteAll()
    do {
        try auth.signOut()
    } catch let error {
        completion(error.localizedDescription)
    }
    self.fb.posts = [Post]()
    self.cd.container = NSPersistentContainer(name: "FreshModel")
    self.cd.container.loadPersistentStores { desc, error in
        if let error = error {
            fatalError(error.localizedDescription)
        }
    }
    self.cd.context = self.cd.container.viewContext
    
    completion(nil)
    
}


}

