//
//  LoginViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/12/21.
//

import UIKit
import TinyConstraints

class LoginViewController: UIViewController {
    
    private let auth = AuthModel.shared
    
    private var stackView = UIView()
    private var scrollView = ScrollView()
    private var bottomConstraint: NSLayoutConstraint!
    private let imageView = UIImageView()
    private var email = TextField(text: "Email", image: nil)
    private var password = TextField(text: "Password", image: nil)
    private let signInButton = Button(text: "Sign In", color: UIColor.theme.blueColor)
    private let createAccountButton = Button(text: "Create Account", color: .clear)
    private var keyboardShowing: Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
    }
    
    private func setupView() {
        // View
        view.backgroundColor = .systemBackground
        
        // Image
        scrollView.addSubview(imageView)
        let image = UIImage(systemName: "book")
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
        scrollView.edgesToSuperview(usingSafeArea: true)
        
        imageView.width(100)
        imageView.height(100)
        imageView.topToSuperview(offset: 100)
        imageView.centerXToSuperview()
        
        stackView.centerYToSuperview(offset: 100)
        stackView.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        stackView.width(view.width - 30)
        
        email.height(50)
        password.height(50)
        signInButton.height(50)
        createAccountButton.height(50)
        
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
        auth.signIn(email: email.text!, password: password.text!)
    }
    
    @objc private func didTapCreateAccountButton() {
        let create = CreateAccountViewController()
        create.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(CreateAccountViewController(), animated: true)
    }
}
