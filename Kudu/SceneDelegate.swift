//
//  SceneDelegate.swift
//  Kudu
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
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
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

