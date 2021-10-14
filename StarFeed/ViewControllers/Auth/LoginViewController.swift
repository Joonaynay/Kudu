//
//  LoginViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/12/21.
//

import UIKit
import TinyConstraints

class LoginViewController: UIViewController {
    
    private let fb = AuthModel.shared
    
    private var stackView = UIView()
    private var scrollView = ScrollView()
    private var bottomConstraint: NSLayoutConstraint!
    private let imageView = UIImageView()
    private var email = TextField(text: "Email")
    private var password = TextField(text: "Password")
    private let signInButton = Button(text: "Sign In")
    private let createAccountButton = Button(text: "Create Account")
    private var keyboardShowing: Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        // View
        view.backgroundColor = .systemBackground
        
        // Image
        let image = UIImage(systemName: "person.circle.fill")
        imageView.image = image
                
        //Sign In Button
        signInButton.addTarget(self, action: #selector(didTapSignInButton), for: .touchUpInside)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Create Account Button
        createAccountButton.backgroundColor = .clear
        createAccountButton.addTarget(self, action: #selector(didTapCreateAccountButton), for: .touchUpInside)
        
        
        //ScrollView
        view.addSubview(scrollView)
        
        //Stack View
        scrollView.addSubview(stackView)
        stackView.stack([
            imageView,
            email,
            password,
            signInButton,
            createAccountButton
            
        ], axis: .vertical, width: nil, height: nil, spacing: 10)
        
        //Detect keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
        
    }
    
    
    private func setupConstraints() {
        
        scrollView.edges(to: view)
        stackView.edgesToSuperview(excluding: .bottom, insets: TinyEdgeInsets(top: 15, left: 15, bottom: 0, right: 15))
        stackView.width(view.width - 30)
        
        email.height(50)
        password.height(50)
        signInButton.height(50)
        createAccountButton.height(50)
        imageView.height(view.width - 30)
        
        
    }
    
    @objc func handleKeyboard(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if notification.name == UIResponder.keyboardDidShowNotification && !keyboardShowing {
                keyboardShowing = true
                if bottomConstraint != nil {
                    bottomConstraint.isActive = false
                }
                bottomConstraint = stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -keyboardSize.height - 50)
                bottomConstraint.isActive = true
            } else if notification.name == UIResponder.keyboardDidHideNotification && keyboardShowing {
                bottomConstraint.isActive = false
                bottomConstraint = stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
                bottomConstraint.isActive = true
                keyboardShowing = false
            }
        }
    }
    
    @objc private func didTapSignInButton() {
        fb.signIn(email: email.text!, password: password.text!, vc: self)
    }
    
    @objc private func didTapCreateAccountButton() {        
        let create = CreateAccountViewController()
        create.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(CreateAccountViewController(), animated: true)
    }
}
