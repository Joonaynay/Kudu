//
//  ProfileViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/12/21.
//

import UIKit
import TinyConstraints

class ProfileViewController: UIViewController {
    
    private let auth = AuthModel.shared
    
    private let scrollView = ScrollView()
    private var backButton = BackButton()
    let stackView = UIView()
            
    
    //Profile Image
    private let profileImage: UIButton = {
        let button = UIButton()
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        return button
    }()
    
    // Username Label
    let username: UILabel = {
        
        let username = UILabel()
        username.textAlignment = .center
        return username
        
    }()
    
    var postTitle: UILabel {
       
        let title = UILabel()
        title.text = "This is my title."
        return title
        
    }
    
    var rectangle: UIView {
        
        let rect = UIView()
        rect.backgroundColor = .blue
        return rect
    }
    var items = [UIView]()

        
    
    //Edit Profile || Follow Button
    let editProfileButton = Button(text: "Edit Profile", color: UIColor.theme.blueColor)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        backButton.vc = self
        if let image = auth.currentUser.profileImage {
            self.profileImage.setImage(image, for: .normal)
        }
    }
    
    private func setupView() {
        
        // View
        view.backgroundColor = .systemBackground
        
        // Back Button
        view.addSubview(backButton)
        backButton.setupBackButton()
        
        //Profile Image
        if let image = auth.currentUser.profileImage {
            profileImage.setImage(image, for: .normal)
            profileImage.imageView!.layer.masksToBounds = false
            profileImage.imageView!.layer.cornerRadius = 75
            profileImage.imageView!.clipsToBounds = true
        } else {
            profileImage.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
        }
        profileImage.addAction(UIAction() { _ in
            self.navigationController?.pushViewController(ProfilePictureViewController(showBackButton: true), animated: true)
        }, for: .touchUpInside)
        
        scrollView.addSubview(profileImage)
        
        
        //Username
        username.text = auth.currentUser.username
        scrollView.addSubview(username)
        
        //Button
        editProfileButton.addAction(UIAction(title: "") { _ in
            self.present(EditProfileViewController(), animated: true)
        }, for: .touchUpInside)
        
        scrollView.addSubview(editProfileButton)
        
        for _ in 1...10 {
            items.append(rectangle)
            rectangle.addSubview(postTitle)
        }
        //Stack View
        stackView.stack(items, spacing: 10)
        
        // ScrollView
        scrollView.addSubview(stackView)
        view.addSubview(scrollView)
        
    }
    
    
    private func setupConstraints() {
        
        profileImage.height(150)
        profileImage.width(150)
        profileImage.centerX(to: scrollView)
        profileImage.top(to: scrollView)

        username.topToBottom(of: profileImage, offset: 20)
        username.centerX(to: scrollView)
        username.horizontalToSuperview(insets: TinyEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))

        editProfileButton.height(50)
        editProfileButton.width(150)
        editProfileButton.centerX(to: scrollView)
        editProfileButton.topToBottom(of: username, offset: 30)

        scrollView.topToBottom(of: backButton)
        scrollView.leadingToSuperview()
        scrollView.trailingToSuperview()
        scrollView.bottomToSuperview()
        
        stackView.topToBottom(of: editProfileButton, offset: 10)
        stackView.leading(to: scrollView)
        stackView.trailing(to: scrollView)
        stackView.bottom(to: scrollView)
        
        stackView.width(view.width)
        for item in items {
            item.heightToWidth(of: stackView, multiplier: 9/16)
        }
    }
}
