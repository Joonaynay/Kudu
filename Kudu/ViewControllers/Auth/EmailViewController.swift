//
//  EmailViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/15/21.
//

import UIKit
import FirebaseAuth

class EmailViewController: UIViewController {
    
    private let activity = UIActivityIndicatorView()
    
    private let auth = AuthModel.shared
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.text = "Waiting for email to be verified..."
        return label
    }()
    
    private let resendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Resend email", for: .normal)
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.setTitleColor(UIColor.theme.accentColor, for: .normal)
        button.setTitleColor(UIColor.theme.secondaryText, for: .highlighted)
        button.setTitleColor(UIColor.theme.secondaryText, for: .disabled)
        button.isEnabled = false
        return button
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.numberOfLines = 1
        label.text = "60"
        label.textColor = UIColor.theme.secondaryText
        return label
    }()
    
    private let changeEmailButton: UIButton = {
       let button = UIButton()
        button.setTitle("Change email", for: .normal)
        button.setTitleColor(UIColor.theme.accentColor, for: .normal)
        button.setTitleColor(UIColor.theme.secondaryText, for: .highlighted)
        return button
    }()
    
    private var num: Int = 60
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        label.text = "You should have recieved an email with a link to verify your account."
        return label
    }()
    
    let showProfilePicturePage: Bool
        
    private var timer: Timer!
    
    private let fb = FirebaseModel.shared
    
    private let nextButton = CustomButton(text: "Next", color: UIColor.theme.blueColor)
    private let signOutButton = CustomButton(text: "Sign Out", color: .clear)
    
    init() {
        if fb.currentUser.profileImage == nil {
            showProfilePicturePage = true
        } else {
            showProfilePicturePage = false
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addConstraints()
    }
    
    func setupView() {
        view.backgroundColor = .systemBackground
                
        //Timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerFire), userInfo: nil, repeats: true)
        
        // Resend Button
        resendButton.addAction(UIAction(title: "") { _ in
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerFire), userInfo: nil, repeats: true)
            self.resendButton.isEnabled = false
            self.num = 60
            self.timerLabel.text = "60"
            Auth.auth().currentUser?.sendEmailVerification(completion: { error in
                if let error = error {
                    let errorAlert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(errorAlert, animated: true)
                }
            })
        }, for: .touchUpInside)
        
        nextButton.addAction(UIAction() { _ in
            self.auth.checkEmail { error in
                if error == nil {
                    if self.showProfilePicturePage {
                        let profilePictureView = ProfilePictureViewController(showBackButton: false)
                        self.navigationController?.pushViewController(profilePictureView, animated: true)
                    } else {
                        let nav = TabBarController()
                        nav.modalTransitionStyle = .flipHorizontal
                        nav.modalPresentationStyle = .fullScreen
                        self.present(nav, animated: true)
                    }
                } else {
                    let alert = UIAlertController(title: nil, message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }, for: .touchUpInside)
        
        signOutButton.addAction(UIAction(title: "") { _ in
            self.auth.signOut { _ in }
            let login = UINavigationController(rootViewController: LoginViewController())
            login.modalTransitionStyle = .flipHorizontal
            login.modalPresentationStyle = .fullScreen
            login.navigationBar.isHidden = true
            self.present(login, animated: true)
        }, for: .touchUpInside)
        
        //Change Email Button
        changeEmailButton.addAction(UIAction() { _ in
            self.navigationController?.pushViewController(ChangeEmailViewController(showVerifyView: false), animated: true)
        }, for: .touchUpInside)
        
        view.addSubview(changeEmailButton)
        view.addSubview(titleLabel)
        view.addSubview(resendButton)
        view.addSubview(timerLabel)
        view.addSubview(activity)
        view.addSubview(descriptionLabel)
        view.addSubview(nextButton)
        view.addSubview(signOutButton)
        activity.startAnimating()
        
    }
    
    @objc func timerFire() {
        if num == 1 {
            resendButton.isEnabled = true
            timerLabel.text = ""
            timer.invalidate()
            timer = nil
        } else {
            num -= 1
            timerLabel.text = "\(num)"
        }
    }
        
    func addConstraints() {
        
        titleLabel.topToSuperview(offset: 10, usingSafeArea: true)
        titleLabel.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        
        resendButton.topToBottom(of: titleLabel, offset: 5)
        resendButton.horizontalToSuperview()
        
        timerLabel.topToBottom(of: resendButton, offset: -5)
        timerLabel.horizontalToSuperview()
        
        changeEmailButton.topToBottom(of: timerLabel, offset: 5)
        changeEmailButton.horizontalToSuperview()
        
        activity.centerInSuperview()
        activity.height(50)
        activity.width(50)
        
        descriptionLabel.bottomToTop(of: nextButton, offset: -15)
        descriptionLabel.horizontalToSuperview()
        
        nextButton.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        nextButton.bottomToTop(of: signOutButton)
        nextButton.height(50)
        
        signOutButton.edgesToSuperview(excluding: .top, insets: UIEdgeInsets(top: 0, left: 15, bottom: 15, right: 15), usingSafeArea: true)
        signOutButton.height(50)
        
    }
}
