//
//  EmailViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/15/21.
//

import UIKit

class EmailViewController: UIViewController {
    
    let activity = UIActivityIndicatorView()
    
    private let auth = AuthModel.shared
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.text = "Waiting for email to be verified..."
        return label
    }()
    
    let resendButton: UIButton = {
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
    
    let timerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.numberOfLines = 1
        label.text = "60"
        label.textColor = UIColor.theme.secondaryText
        return label
    }()
    
    var num: Int = 60
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        label.text = "You should have recieved an email with a link to verify your account."
        return label
    }()
        
    var timer: Timer!
    
    let nextButton = Button(text: "Next", color: UIColor.theme.blueColor)
    let cancelButton = Button(text: "Cancel", color: .clear)
    
    
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
        }, for: .touchUpInside)
        
        nextButton.addAction(UIAction(title: "") { _ in
            self.auth.checkEmail { error in
                if error == nil {
                    let profilePictureView = ProfilePictureViewController(showBackButton: false)
                    profilePictureView.modalPresentationStyle = .fullScreen
                    self.present(profilePictureView, animated: true)
                } else {
                    let alert = UIAlertController(title: nil, message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }, for: .touchUpInside)
        
        cancelButton.addAction(UIAction(title: "") { _ in
            let alert = UIAlertController(title: "Clicking cancel will delete your account.", message: "You wil have to create a new account to use the app later. Are you sure you want to cancel?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                self.auth.deleteUser { error in
                    if error == nil {
                        let navLogin = UINavigationController(rootViewController: LoginViewController())
                        navLogin.modalPresentationStyle = .fullScreen
                        navLogin.navigationBar.isHidden = true
                        self.present(navLogin, animated: true)
                    }                    
                }
            }))
            self.present(alert, animated: true)
            
        }, for: .touchUpInside)
        
        view.addSubview(titleLabel)
        view.addSubview(resendButton)
        view.addSubview(timerLabel)
        view.addSubview(activity)
        view.addSubview(descriptionLabel)
        view.addSubview(nextButton)
        view.addSubview(cancelButton)
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
        
        
        activity.centerInSuperview()
        activity.height(50)
        activity.width(50)
        
        descriptionLabel.bottomToTop(of: nextButton, offset: -15)
        descriptionLabel.horizontalToSuperview()
        
        nextButton.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        nextButton.bottomToTop(of: cancelButton)
        nextButton.height(50)
        
        cancelButton.edgesToSuperview(excluding: .top, insets: UIEdgeInsets(top: 0, left: 15, bottom: 15, right: 15), usingSafeArea: true)
        cancelButton.height(50)
        
    }
}
