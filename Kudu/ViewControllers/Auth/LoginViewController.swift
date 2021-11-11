//
//  LoginViewController.swift
//  Kudu
//
//  Created by Forrest Buhler on 10/12/21.
//

import UIKit
import FirebaseAuth
import TinyConstraints

class LoginViewController: UIViewController {
    
    private let auth = AuthModel.shared
    
    private let progressView = ProgressView()
    
    private var stackView = UIView()
    private var scrollView = CustomScrollView()
    private var bottomConstraint: NSLayoutConstraint!
    private let imageView = UIImageView()
    private var email = CustomTextField(text: "Email", image: nil)
    private var password = CustomTextField(text: "Password", image: nil)
    private let signInButton = CustomButton(text: "Sign In", color: UIColor.theme.blueColor)
    private let createAccountButton = CustomButton(text: "Create Account", color: .clear)
    private var keyboardShowing: Bool = false
    private let forgotPasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Forgot Password", for: .normal)
        button.contentHorizontalAlignment = .right
        button.setTitleColor(.systemGray2, for: .highlighted)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .caption1)
        return button
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        // View
        view.backgroundColor = .systemBackground
        
        // ProgressView
        view.addSubview(progressView)
        
        // Image
        scrollView.addSubview(imageView)
        let image = UIImage(named: "logo.png")
        imageView.image = image
        
        //Email
        email.vc = self
        email.keyboardType = .emailAddress
        email.autocorrectionType = .no
        email.returnKeyType = .next
        email.tag = 0
        
        //Password
        password.vc = self
        password.isSecureTextEntry = true
        password.tag = 1
        forgotPasswordButton.addAction(UIAction() { _ in
            let emailAlert = UIAlertController(title: "Reset Email", message: "Please type in your email to recieve a link to reset your password.", preferredStyle: .alert)
            emailAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            emailAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
                self.auth.forgotPassword(email: emailAlert.textFields!.first!.text!) { [weak self] error in
                    guard let self = self else { return }
                    if let error = error {
                        let errorAlert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel))
                        self.present(errorAlert, animated: true)
                    } else {
                        let successAlert = UIAlertController(title: "Success", message: "Successfully sent an email to \(emailAlert.textFields!.first!.text!)", preferredStyle: .alert)
                        successAlert.addAction(UIAlertAction(title: "OK", style: .cancel))
                        self.present(successAlert, animated: true)
                    }
                }
            }))
            emailAlert.addTextField { textField in
                textField.placeholder = "Email"
            }
            self.present(emailAlert, animated: true)

        }, for: .touchUpInside)
        
        //Sign In Button
        signInButton.addTarget(self, action: #selector(didTapSignInButton), for: .touchUpInside)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Create Account Button
        createAccountButton.backgroundColor = .clear
        createAccountButton.addTarget(self, action: #selector(didTapCreateAccountButton), for: .touchUpInside)
        
        //ScrollView
        view.addSubview(scrollView)
        scrollView.refreshControl = nil
        
        //Stack View
        scrollView.addSubview(stackView)
        stackView.stack([
            email,
            password,
            forgotPasswordButton,
            signInButton,
            createAccountButton
        ], axis: .vertical, width: nil, height: nil, spacing: 10)
        
        //Detect keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
        
    }
    
    
    private func setupConstraints() {
        scrollView.edgesToSuperview(usingSafeArea: true)
        
        imageView.width(300)
        imageView.height(300)
        imageView.topToSuperview(offset: 50)
        imageView.centerXToSuperview()
        
        stackView.topToBottom(of: imageView)
        stackView.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        stackView.width(view.width - 30)
        
        email.height(50)
        password.height(50)
        signInButton.height(50)
        createAccountButton.height(50)
        
        forgotPasswordButton.height(25)
                
        progressView.edgesToSuperview()
        view.bringSubviewToFront(progressView)
        
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
        self.progressView.start()
        auth.signIn(email: email.text!, password: password.text!) { [weak self] error in
            guard let self = self else { return }
            if error == nil {
                if Auth.auth().currentUser?.isEmailVerified == true {
                    self.progressView.stop()
                    let tab = TabBarController()
                    tab.modalTransitionStyle = .flipHorizontal
                    tab.modalPresentationStyle = .fullScreen
                    self.present(tab, animated: true)
                } else {
                    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                    self.navigationController?.pushViewController(EmailViewController(), animated: true)
                }
            } else {
                self.progressView.stop()
                let alert = UIAlertController(title: nil, message: error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                self.present(alert, animated: true)
            }
        }
    }
    
    @objc private func didTapCreateAccountButton() {
        let create = CreateAccountViewController()
        create.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(CreateAccountViewController(), animated: true)
    }
}
