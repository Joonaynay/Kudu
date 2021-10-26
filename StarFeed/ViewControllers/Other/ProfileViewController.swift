//
//  ProfileViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/12/21.
//

import UIKit
import TinyConstraints

class ProfileViewController: UIViewController {
    
    private let fb = FirebaseModel.shared
    
    private let scrollView = CustomScrollView()
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
    var posts = [UIView]()
    
    //Edit Profile || Follow Button
    let editProfileButton = CustomButton(text: "Edit Profile", color: UIColor.theme.blueColor)
    
    private let user: User
    
    private let rectangleLine = UIView()
    
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        backButton.vc = self
        if let image = self.user.profileImage {
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
        if let image = user.profileImage {
            profileImage.setImage(image, for: .normal)
        } else {
            profileImage.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
        }
        profileImage.imageView!.layer.masksToBounds = false
        profileImage.imageView!.layer.cornerRadius = 75
        profileImage.imageView!.clipsToBounds = true
        
        profileImage.addAction(UIAction() { _ in
            self.navigationController?.pushViewController(ProfilePictureViewController(showBackButton: true), animated: true)
        }, for: .touchUpInside)
        
        scrollView.addSubview(profileImage)
        scrollView.refreshControl = nil
        
        //Username
        username.text = user.username
        scrollView.addSubview(username)
        
        //Button
        editProfileButton.addAction(UIAction(title: "") { _ in
            self.present(EditProfileViewController(), animated: true)
        }, for: .touchUpInside)
        
        // Scrollview
        scrollView.addSubview(editProfileButton)
        
        for postView in fb.posts {
            if postView.post.user.id == self.user.id {
                postView.vc = self
                posts.append(postView)
            }
        }
        
        //Stack View
        stackView.stack(posts)
        
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
        

        stackView.edgesToSuperview(excluding: .top)
        stackView.topToBottom(of: editProfileButton, offset: 40)
        stackView.width(view.width)
        
        for post in posts {
            post.heightToWidth(of: stackView)
        }
    }
}
