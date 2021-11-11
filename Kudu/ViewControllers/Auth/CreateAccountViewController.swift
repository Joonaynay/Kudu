//
//  CreateAccountViewController.swift
//  Kudu
//
//  Created by Forrest Buhler on 10/13/21.
//

import UIKit
import TinyConstraints

class CreateAccountViewController: UIViewController {
    
    private let auth = AuthModel.shared
        
    private let progressView = ProgressView()
    private let scrollView = CustomScrollView()
    private let stackView = UIView()
    public var firstName = CustomTextField(text: "First Name", image: nil)
    public var lastName = CustomTextField(text: "Last Name", image: nil)
    public var username = CustomTextField(text: "Username", image: nil)
    public var email = CustomTextField(text: "Email", image: nil)
    public var password = CustomTextField(text: "Password", image: nil)
    public var confirmPassword = CustomTextField(text: "Confirm Password", image: nil)
    public var agePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.contentHorizontalAlignment = .left
        picker.datePickerMode = .date
        return picker
    }()
    
    private var bottomConstraint: NSLayoutConstraint!
    private var keyboardShowing: Bool = false
    
    private var header: UILabel {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 10, weight: .heavy)
        return label
    }
    private let backButton = BackButton()
    
    public let createAccountButton = CustomButton(text: "Create Account", color: UIColor.theme.blueColor)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        backButton.vc = self
        firstName.vc = self
        lastName.vc = self
        username.vc = self
        email.vc = self
        password.vc = self
        confirmPassword.vc = self
    }
    
    private func setupView() {
        // Set tags
        firstName.tag = 0
        firstName.returnKeyType = .next
        lastName.tag = 1
        lastName.returnKeyType = .next
        username.tag = 2
        username.returnKeyType = .next
        email.tag = 3
        email.returnKeyType = .next
        password.tag = 4
        password.returnKeyType = .next
        confirmPassword.tag = 5
        
        // View
        view.backgroundColor = .systemBackground
        
        // ProgressView
        view.addSubview(progressView)
        
        //Text Fields
        let name = header
        name.text = "NAME"
                
        let usernameHeader = header
        usernameHeader.text = "USERNAME"
                
        let emailHeader = header
        emailHeader.text = "EMAIL"
        
        let passwordHeader = header
        passwordHeader.text = "PASSWORD"
        
        let ageHeader = header
        ageHeader.text = "BIRTHDAY"
        
        //BackButton
        view.addSubview(backButton)
        backButton.setupBackButton()
        
        //Password and Confirm
        password.isSecureTextEntry = true
        confirmPassword.isSecureTextEntry = true
        
        //Create Account Button
        createAccountButton.isEnabled = false
        createAccountButton.addAction(UIAction(title: "") { [weak self] _ in
            guard let self = self else { return }
            self.progressView.start()
            self.isEditing = false
            self.auth.signUp(email: self.email.text!, password: self.password.text!, confirm: self.confirmPassword.text!, name: "\(self.firstName.text!) \(self.lastName.text!)", username: self.username.text!, age: self.agePicker.date) { error in
                if error == nil {
                    self.progressView.stop()
                    let email = EmailViewController()
                    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                    self.navigationController?.pushViewController(email, animated: true)
                } else {
                    self.progressView.stop()
                    let alert = UIAlertController(title: nil, message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default))
                    self.present(alert, animated: true)
                }
            }
            
        }, for: .touchUpInside)
        
        
        //Scroll View
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        scrollView.refreshControl = nil
        
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
            ageHeader,
            agePicker,
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
        agePicker.height(40)
        createAccountButton.height(50)
        
        
        progressView.edgesToSuperview()
        view.bringSubviewToFront(progressView)
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
    
}

