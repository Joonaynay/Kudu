//
//  CreateAccountViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/13/21.
//

import UIKit
import TinyConstraints

class CreateAccountViewController: UIViewController {
    
    private let fb = AuthModel.shared
    
    private let scrollView = ScrollView()
    private let stackView = UIView()
    
    private var firstName = TextField(text: "First Name")
    private var lastName = TextField(text: "Last Name")
    private var username = TextField(text: "Username")
    private var email = TextField(text: "Email")
    private var password = TextField(text: "Password")
    private var confirmPassword = TextField(text: "Confirm Password")
    
    private var bottomConstraint: NSLayoutConstraint!

    
    private var keyboardShowing: Bool = false
    
    private var header: UILabel {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 8, weight: .heavy)
        return label
    }
    
    private var backButton: BackButton!
    private let createAccountButton = Button(text: "Create Account")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addConstraints()
    }
    
    private func setupView() {
        // View
        view.backgroundColor = .systemBackground
        
        //Text Fields
        let name = header
        name.text = "NAME"
                
        let usernameHeader = header
        usernameHeader.text = "USERNAME"
                
        let emailHeader = header
        emailHeader.text = "EMAIL"
        
        let passwordHeader = header
        passwordHeader.text = "PASSWORD"
        
        //BackButton
        backButton = BackButton(vc: self)
        
        //Password and Confirm
        password.isSecureTextEntry = true
        confirmPassword.isSecureTextEntry = true
        
        //Create Account Button
        createAccountButton.addTarget(self, action: #selector(didTapCreateAccountButton), for: .touchUpInside)
        
        //Scroll View
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        //Stack View
        stackView.stack([
            name,
            firstName,
            lastName,
            usernameHeader,
            username,
            emailHeader,
            email,
            passwordHeader,
            password,
            confirmPassword,
            createAccountButton
        ], axis: .vertical, width: nil, height: nil, spacing: 10)
        
        //Detect keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
        
    }
    
    
    private func addConstraints() {
        
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.topToBottom(of: backButton)
        scrollView.leading(to: view)
        scrollView.trailing(to: view)
        
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        stackView.top(to: scrollView)
        stackView.leading(to: scrollView, offset: 15)
        stackView.trailing(to: scrollView, offset: -15)
        stackView.width(view.width - 30)
        
        firstName.height(50)
        lastName.height(50)
        username.height(50)
        email.height(50)
        password.height(50)
        confirmPassword.height(50)
        createAccountButton.height(50)
    }
    
    @objc func handleKeyboard(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if notification.name == UIResponder.keyboardDidShowNotification && !keyboardShowing {
                if bottomConstraint != nil {
                    bottomConstraint.isActive = false
                }
                bottomConstraint = stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -keyboardSize.height - 50)
                bottomConstraint.isActive = true
                keyboardShowing = true
            } else if notification.name == UIResponder.keyboardDidHideNotification && keyboardShowing {
                bottomConstraint.isActive = false
                bottomConstraint = stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
                bottomConstraint.isActive = true
                keyboardShowing = false
            }
        }
    }
    
    
    @objc private func didTapCreateAccountButton() {
        self.view.endEditing(true)
    }
}

