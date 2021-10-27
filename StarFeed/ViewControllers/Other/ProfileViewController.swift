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
    
    private let infoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
        button.tintColor = UIColor.theme.accentColor
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        return button
    }()
    
    //Profile Image
    private let profileImage: UIButton = {
        let button = UIButton()
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.isEnabled = false
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
    let editProfileButton = CustomButton(text: "", color: UIColor.theme.blueColor)
    
    private var user: User
    
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        backButton.vc = self
        if let image = self.user.profileImage {
            self.profileImage.setImage(image, for: .normal)
            self.profileImage.setImage(image, for: .disabled)
        }
        if fb.currentUser.id != user.id {
            self.editProfileButton.label.text = self.fb.currentUser.following.contains(self.user.id) ? "Unfollow" : "Follow"
            fb.loadUser(uid: user.id) { user in
                if let user = user {
                    if let index = self.fb.users.firstIndex(where: { users in
                        users.id == user.id
                    }) {
                        self.fb.users[index] = user
                        self.user = user
                        let menu = UIMenu(title: "", image: nil, options: .displayInline, children: [
                            UIAction(title: "Followers: \(user.followers.count)", image: UIImage(systemName: "person"), handler: { _ in }),
                            UIAction(title: "Posts: \(user.posts.count)", image: UIImage(systemName: "camera"), handler: { _ in })
                        ])
                        self.infoButton.menu = menu
                    }
                }
            }
        }
    }
    
    
    private func setupView() {
        
        // View
        view.backgroundColor = .systemBackground
        
        // Back Button
        view.addSubview(backButton)
        backButton.setupBackButton()
        
        // Info Button
        let menu = UIMenu(title: "", image: nil, options: .displayInline, children: [
            UIAction(title: "Followers: \(user.followers.count)", image: UIImage(systemName: "person"), handler: { _ in }),
            UIAction(title: "Posts: \(user.posts.count)", image: UIImage(systemName: "camera"), handler: { _ in })
        ])
        infoButton.menu = menu
        infoButton.showsMenuAsPrimaryAction = true
        
        view.addSubview(infoButton)
        
        //Profile Image
        if let image = user.profileImage {
            profileImage.setImage(image, for: .normal)
        } else {
            profileImage.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
        }
        profileImage.imageView!.layer.masksToBounds = false
        profileImage.imageView!.layer.cornerRadius = 75
        profileImage.imageView!.clipsToBounds = true
        
        if fb.currentUser.id == user.id {
            profileImage.isEnabled = true
            profileImage.addAction(UIAction() { _ in
                self.navigationController?.pushViewController(ProfilePictureViewController(showBackButton: true), animated: true)
            }, for: .touchUpInside)
        }
        
        scrollView.addSubview(profileImage)
        scrollView.refreshControl = nil
        
        //Username
        username.text = user.username
        scrollView.addSubview(username)
        
        //Button
        if fb.currentUser.id == user.id {
            editProfileButton.label.text = "Edit Profile"
            editProfileButton.addAction(UIAction() { _ in
                self.present(EditProfileViewController(), animated: true)
            }, for: .touchUpInside)
        } else {
            editProfileButton.addAction(UIAction() { _ in
                self.fb.followUser(followUser: self.user) {
                    self.editProfileButton.label.text = self.fb.currentUser.following.contains(self.user.id) ? "Unfollow" : "Follow"
                }
            }, for: .touchUpInside)
        }
        
        // Scrollview
        scrollView.addSubview(editProfileButton)
        
        for pview in fb.posts {
            if pview.post.uid == self.user.id {
                pview.vc = self
                posts.append(pview)
            }
        }
        
        //Stack View
        stackView.stack(posts)
        
        // ScrollView
        scrollView.addSubview(stackView)
        view.addSubview(scrollView)
        
    }
    
    
    private func setupConstraints() {
        
        infoButton.topToSuperview(offset: 21, usingSafeArea: true)
        infoButton.trailingToSuperview(offset: 12)
        infoButton.height(23)
        infoButton.width(23)
        
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
        stackView.leading(to: scrollView)
        stackView.trailing(to: scrollView)
        stackView.bottom(to: scrollView)
        stackView.width(view.width)
        
        for post in posts {
            post.heightToWidth(of: stackView)
        }
    }
}
