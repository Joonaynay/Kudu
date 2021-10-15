//
//  AuthModel.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/13/21.
//

import UIKit

class AuthModel: ObservableObject {
    static let shared = AuthModel()
    
    @Published public var signedIn = false
    
    func signIn(email: String, password: String, vc: UIViewController) {
        
        let tab = TabBarController()
        tab.modalPresentationStyle = .fullScreen
        vc.present(tab, animated: true)
        
    }
    
    func signOut(vc: UIViewController) {
        vc.dismiss(animated: false)
    }
    
}
