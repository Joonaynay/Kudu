//
//  AuthModel.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/13/21.
//

import UIKit

class AuthModel: ObservableObject {
    static let shared = AuthModel()
    
    weak var vc: UIViewController?
    
    @Published public var signedIn = false
    
    func signIn(email: String, password: String) {
        
        let tab = TabBarController()
        tab.modalPresentationStyle = .fullScreen
        
        if let vc = vc {
            vc.present(tab, animated: true)
        }
        
    }
    
    func signOut() {
        if let vc = vc {
            vc.dismiss(animated: false)
        }
    }
    
}
