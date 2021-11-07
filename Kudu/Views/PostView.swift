//
//  PostView.swift
//  Kudu
//
//  Created by Wendy Buhler on 10/14/21.
//

import UIKit
import FirebaseFirestore

class PostView: UICollectionViewCell {
    
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
    
    private lazy var imageViewButtonAction: UIAction = {
        let action = UIAction() { _ in
            if let movie = self.fb.posts[self.post!].movie {
                self.vc?.present(VideoPlayer(url: movie), animated: true)
            }
        }
        return action
    }()
    
    //Button to move to comments
    private let commentsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Comments", for: .normal)
        button.setTitleColor(UIColor.theme.lineColor, for: .normal)
        button.setTitleColor(UIColor.theme.secondaryText, for: .highlighted)
        return button
    }()
    private lazy var commentsButtonAction: UIAction = {
        let action = UIAction() { _ in
            let comments = CommentsViewController(post: self.fb.posts[self.post!])
            comments.hidesBottomBarWhenPushed = true
            self.vc?.navigationController?.pushViewController(comments, animated: true)
        }
        return action
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
    private lazy var infoButtonAction: UIAction = {
        let action = UIAction() { _ in
            let details = VideoDetailsViewController(post: self.fb.posts[self.post!])
            details.vc = self.vc
            details.modalPresentationStyle = .pageSheet
            self.vc?.present(details, animated: true)
        }
        return action
    }()
    // Info Button
    private let infoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.tintColor = UIColor.theme.accentColor
        return button
    }()
    private lazy var likeButtonAction: UIAction = {
        let action = UIAction() { _ in
            self.fb.likePost(post: self.post!)
            if self.fb.currentUser.likes.contains(self.fb.posts[self.post!].id) {
                    self.likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
                    self.likeButton.tintColor = UIColor.theme.blueColor
                } else {
                    self.likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
                    self.likeButton.tintColor = .label
                }
            let result = String(format: "%ld %@", locale: Locale.current, self.fb.posts[self.post!].likeCount, "")
            self.likeCount.text = result
        }
        return action
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
    private let line: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        return view
    }()
    //Has Profile Image and username
    private let profile = ProfileButton(image: nil, username: "")
    private lazy var profileAction: UIAction = {
        let action = UIAction() { _ in
            if let index = self.fb.users.firstIndex(where: { user in
                user.id == self.fb.posts[self.post!].uid
            }) {
                let profileView = ProfileViewController(user: self.fb.users[index])
                profileView.hidesBottomBarWhenPushed = true
                self.vc?.navigationController?.pushViewController(profileView, animated: true)
            }
        }
        return action
    }()
    
    private let followButton = CustomButton(text: "", color: UIColor.theme.blueColor)
    private lazy var followButtonAction: UIAction = {
        let action = UIAction() { _ in
            self.fb.followUser(followUser: self.fb.users[self.user!]) {
                if self.fb.currentUser.following.contains(self.fb.users[self.user!].id) {
                    self.followButton.label.text = "Unfollow"
                } else {
                    self.followButton.label.text = "Follow"
                }
                if let superview = self.superview as? CustomCollectionView {
                    superview.reloadData()
                }
            }
        }
        return action
    }()
    
    public var post: Int?
    private var user: Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)        
        contentView.addSubview(commentsButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoButton)
        contentView.addSubview(imageViewButton)
        contentView.addSubview(likeButton)
        contentView.addSubview(followButton)
        contentView.addSubview(profile)
        contentView.addSubview(likeCount)
        contentView.addSubview(date)
        contentView.addSubview(line)
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupView(post: Post) {
        guard let post = fb.posts.firstIndex(where: { p in p.id == post.id }) else { return }
        self.post = post
        guard let user = fb.users.firstIndex(where: { user in user.id == fb.posts[post].uid }) else { return }
        self.user = user
        
        
        if fb.currentUser.likes.contains(fb.posts[post].id) {
                self.likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
                self.likeButton.tintColor = UIColor.theme.blueColor
            } else {
                self.likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
                self.likeButton.tintColor = .label
            }
        let result = String(format: "%ld %@", locale: Locale.current, fb.posts[post].likeCount, "")
        likeCount.text = result
            
        
        //Button Actions
        infoButton.addAction(infoButtonAction, for: .touchUpInside)
        likeButton.addAction(likeButtonAction, for: .touchUpInside)
        followButton.addAction(followButtonAction, for: .touchUpInside)
        imageViewButton.addAction(imageViewButtonAction, for: .touchUpInside)
        profile.addAction(profileAction, for: .touchUpInside)
        commentsButton.addAction(commentsButtonAction, for: .touchUpInside)
        
        //Date
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .long
        let dateString = dateFormatter.string(from: fb.posts[post].date)
        date.text = dateString
        
        //Set follow button text
        if self.fb.currentUser.following.contains(fb.users[user].id) {
            self.followButton.label.text = "Unfollow"
        } else {
            self.followButton.label.text = "Follow"
        }
        
        //Set imageview image
        imageViewButton.isEnabled = false
        if fb.posts[post].movie != nil {
            imageViewButton.isEnabled = true
            let playButton = UIImageView(image: UIImage(systemName: "play.circle.fill"))
            playButton.contentMode = .scaleAspectFill
            imageViewButton.addSubview(playButton)
            playButton.centerInSuperview()
            playButton.height(50)
            playButton.width(50)
            
        }
        imageViewButton.setImage(fb.posts[post].image, for: .normal)
        imageViewButton.setImage(fb.posts[post].image, for: .disabled)
        imageViewButton.imageView!.contentMode = .scaleAspectFill
        
        //Set user image
        profile.usernameLabel.text = fb.users[user].username
        profile.profileImage.image = fb.users[user].profileImage
        
        //Set post title
        titleLabel.text = fb.posts[post].title
        
        
        
    }
    
    override func prepareForReuse() {
        //Remove all actions
        infoButton.removeAction(infoButtonAction, for: .touchUpInside)
        likeButton.removeAction(likeButtonAction, for: .touchUpInside)
        imageViewButton.removeAction(imageViewButtonAction, for: .touchUpInside)
        profile.removeAction(profileAction, for: .touchUpInside)
        commentsButton.removeAction(commentsButtonAction, for: .touchUpInside)
        followButton.removeAction(followButtonAction, for: .touchUpInside)
        
        //Remove any other text or images
        for subview in imageViewButton.subviews {
            if let subview = subview as? UIImageView, subview.image == UIImage(systemName: "play.circle.fill") {
                subview.removeFromSuperview()
            }
        }
        imageViewButton.setImage(nil, for: .normal)
        profile.profileImage.image = nil
        titleLabel.text = nil
        date.text = nil
        self.followButton.label.text = nil
    }
    
    
    private func addConstraints() {
        
        imageViewButton.edgesToSuperview(excluding: .bottom)
        imageViewButton.heightToWidth(of: self, multiplier: 9/16 )
        imageViewButton.widthToSuperview()
        
        infoButton.leftToRight(of: titleLabel, offset: 6)
        infoButton.topToBottom(of: imageViewButton, offset: 15)
        infoButton.width(30)
        infoButton.height(30)
        
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
        
        line.horizontalToSuperview()
        line.bottomToSuperview()
        line.height(1)
        
    }
    
}


