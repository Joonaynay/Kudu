//
//  PostView.swift
//  StarFeed
//
//  Created by Wendy Buhler on 10/14/21.
//

import UIKit
import FirebaseFirestore

class PostView: UIView {
    
    let fb = FirebaseModel.shared
    
    weak var vc: UIViewController?
    
    //Post Title
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .label
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        titleLabel.numberOfLines = 2
        return titleLabel
    }()
    
    //Main Image/Thumbnail
    private let imageViewButton: UIButton = {
        let button = UIButton()
        return button
    }()
        
    //Button to move to comments
    private let commentsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Comments", for: .normal)
        button.setTitleColor(UIColor.theme.lineColor, for: .normal)
        button.setTitleColor(UIColor.theme.secondaryText, for: .highlighted)
        return button
    }()
    
    //Like Count Label
    private let likeCount: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    
    //Button to like
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        button.tintColor = .label
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        return button
    }()
    
    // Info Button
    private let infoButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.tintColor = UIColor.theme.blueColor
        return button
    }()
    
    // Date of post
    private let date: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.theme.lineColor
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        return label
    }()
    
    //Has Profile Image and username
    private let profile = ProfileButton(image: nil, username: "")
    
    private let followButton = CustomButton(text: "Follow", color: UIColor.theme.blueColor)
    
    private var first = true
    
    public var post: Post
    
    init(post: Post) {
        self.post = post
        super.init(frame: .zero)
        height(UIScreen.main.bounds.width)
        addSubview(commentsButton)
        addSubview(titleLabel)
        addSubview(infoButton)
        addSubview(imageViewButton)
        addSubview(likeButton)
        addSubview(followButton)
        addSubview(profile)
        addSubview(likeCount)
        addSubview(date)
        setupView()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        var post = post
        guard let user = fb.users.first(where: { user in
            user.id == post.uid
        }) else { return }
        
        let db = Firestore.firestore()
        db.collection("posts").document(post.id).addSnapshotListener { doc, error in
            guard let likes = doc?.get("likes") as? [String] else { return }
            if likes.contains(self.fb.currentUser.id) {
                self.likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
                self.likeButton.tintColor = UIColor.theme.blueColor
            } else {
                self.likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
                self.likeButton.tintColor = .label
            }
            let result = String(format: "%ld %@", locale: Locale.current, likes.count, "")
            self.likeCount.text = result
        }
        
        infoButton.addAction(UIAction() { _ in
            let details = VideoDetailsViewController(post: post)
            details.modalPresentationStyle = .pageSheet
            self.vc?.present(details, animated: true)
        }, for: .touchUpInside)
        
        likeButton.addAction(UIAction() { _ in
            self.fb.likePost(currentPost: post)
            if let index = post.likes.firstIndex(of: self.fb.currentUser.id) {
                post.likes.remove(at: index)
            } else {
                post.likes.append(self.fb.currentUser.id)
            }
        }, for: .touchUpInside)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .long
        let dateString = dateFormatter.string(from: post.date)
        date.text = dateString
        
        followButton.addAction(UIAction() { _ in
            self.fb.followUser(followUser: user) {
                if self.fb.currentUser.following.contains(user.id) {
                    self.followButton.label.text = "Unfollow"
                } else {
                    self.followButton.label.text = "Follow"
                }
            }
        }, for: .touchUpInside)
        
        imageViewButton.addAction(UIAction() { _ in
            self.vc?.present(VideoPlayer(url: post.movie!), animated: true)
        }, for: .touchUpInside)
        
        profile.addAction(UIAction() { _ in
            if let index = self.fb.users.firstIndex(where: { user in
                user.id == post.uid
            }) {
                let profileView = ProfileViewController(user: self.fb.users[index])
                profileView.hidesBottomBarWhenPushed = true
                self.vc?.navigationController?.pushViewController(profileView, animated: true)
            }
            

        }, for: .touchUpInside)
        
        imageViewButton.setBackgroundImage(post.image, for: .normal)
        
        
        profile.profileImage.image = user.profileImage
        
        titleLabel.text = post.title
        
        commentsButton.addAction(UIAction() { _ in
            let comments = CommentsViewController(post: post)
            comments.hidesBottomBarWhenPushed = true
            self.vc?.navigationController?.pushViewController(comments, animated: true)
            
        }, for: .touchUpInside)
        
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        guard let user = fb.users.first(where: { user in
            user.id == post.uid
        }) else { return }

        if fb.currentUser.following.contains(user.id) {
            followButton.label.text = "Unfollow"
        } else {
            followButton.label.text = "Follow"
        }
        profile.profileImage.image = user.profileImage
        profile.usernameLabel.text = user.username
    }
        
    
    
    private func addConstraints() {
        
        imageViewButton.edgesToSuperview(excluding: .bottom)
        imageViewButton.heightToWidth(of: self, multiplier: 9/16 )
        imageViewButton.widthToSuperview()
        
        infoButton.leftToRight(of: titleLabel, offset: 8)
        infoButton.topToBottom(of: imageViewButton, offset: 15)
        infoButton.width(25)
        infoButton.height(25)
        
        titleLabel.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 40))
        titleLabel.topToBottom(of: imageViewButton, offset: 5)
        titleLabel.height(60)
        
        likeButton.topToBottom(of: titleLabel, offset: 10)
        likeButton.trailingToSuperview(offset: 10)
        likeButton.height(32)
        likeButton.width(32)
        
        profile.leadingToSuperview(offset: 5)
        profile.topToBottom(of: titleLabel, offset: 10)
        profile.widthToSuperview(multiplier: 0.4)
        
        likeCount.trailingToLeading(of: likeButton, offset: -5)
        likeCount.topToBottom(of: titleLabel, offset: 15)
        
        followButton.topToBottom(of: titleLabel, offset: 5)
        followButton.trailingToLeading(of: likeCount, offset: -10)
        followButton.height(50)
        followButton.width(UIScreen.main.bounds.width / 4)
        
        date.bottomToSuperview(offset: -15)
        date.trailingToSuperview(offset: 5)
        
        commentsButton.bottomToSuperview(offset: -5)
        commentsButton.leadingToSuperview(offset: 5)
        
    }
    
}


