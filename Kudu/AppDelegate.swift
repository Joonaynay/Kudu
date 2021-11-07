//
//  AppDelegate.swift
//  Kudu
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit
import FirebaseAuth
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        
        let fb = FirebaseModel.shared
        if let uid = UserDefaults.standard.value(forKey: "uid") as? String, Auth.auth().currentUser?.email != nil {
            fb.loadUser(uid: uid) { user in
                if let user = user {
                    if Auth.auth().currentUser?.isEmailVerified == true {
                        window.rootViewController = TabBarController()
                    } else {
                        let nav = UINavigationController(rootViewController: EmailViewController())
                        nav.navigationBar.isHidden = true
                        window.rootViewController = nav
                    }
                    fb.currentUser = user
                } else {
                    //Check if can load from Core Data
                    let cd = Persistence()
                    let file = FileManagerModel.shared
                    if let user = cd.fetchUser(uid: uid) {
                        print("Loaded User From Core Data")
                        
                        var profileImage: UIImage?
                        if let image = file.getFromFileManager(id: uid) {
                            profileImage = image
                        } else {
                            profileImage = nil
                        }
                        let user = User(id: user.id!, username: user.username!, name: user.name!, likes: user.likes!, profileImage: profileImage, following: user.following!, followers: user.followers! ,posts: user.posts!)
                        if !fb.users.contains(where: { users in
                            user.id == users.id
                        }) {
                            fb.users.append(user)
                        }
                        fb.currentUser = user
                        window.rootViewController = TabBarController()
                    } else {
                        let loginNav = UINavigationController(rootViewController: LoginViewController())
                        loginNav.navigationBar.isHidden = true
                        window.rootViewController = loginNav
                    }
                }
            }
        } else {
            let loginNav = UINavigationController(rootViewController: LoginViewController())
            loginNav.navigationBar.isHidden = true
            window.rootViewController = loginNav
        }
        self.window = window
            
            return true
        }
        
        // MARK: UISceneSession Lifecycle
        
        func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
            // Called when a new scene session is being created.
            // Use this method to select a configuration to create the new scene with.
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        }
        
        func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
            // Called when the user discards a scene session.
            // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
            // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        }
        
        
    }
    
