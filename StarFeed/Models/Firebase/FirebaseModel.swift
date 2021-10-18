//
//  FirebaseModel.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/14/21.
//

import Foundation

class FirebaseModel: ObservableObject {
    
    static let shared = FirebaseModel()
    
    private let file = FileManagerModel.shared
    private let storage = StorageModel.shared
    private let cd = Persistence.shared
    private let db = FirestoreModel.shared
    
    @Published public var users = [User]()
    @Published public var subjects: [Subject] = [Subject(name: "Business", image: "building.2.fill"), Subject(name: "Politics", image: "building.columns.fill"), Subject(name: "Business", image: "building.2.fill"), Subject(name: "Politics", image: "building.columns.fill"),Subject(name: "Business", image: "building.2.fill"), Subject(name: "Politics", image: "building.columns.fill"),Subject(name: "Business", image: "building.2.fill"), Subject(name: "Politics", image: "building.columns.fill"),Subject(name: "Business", image: "building.2.fill"), Subject(name: "Politics", image: "building.columns.fill"),Subject(name: "Business", image: "building.2.fill"), Subject(name: "Politics", image: "building.columns.fill"),Subject(name: "Business", image: "building.2.fill"), Subject(name: "Politics", image: "building.columns.fill"),Subject(name: "Business", image: "building.2.fill"), Subject(name: "Politics", image: "building.columns.fill")]
        
    
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
}
