//
//  PostView.swift
//  StarFeed
//
//  Created by Wendy Buhler on 10/14/21.
//

import UIKit

class PostView: UICollectionViewCell {
    
    private let titleLabel: UILabel = {
       
        let titleLabel = UILabel()
        titleLabel.textColor = .label
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        titleLabel.numberOfLines = 3
        return titleLabel
    }()
    
    private let imageView: UIImageView = {
       
        let image = UIImageView()
        image.backgroundColor = .blue
        return image
        
    }()
    
    private let commentsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Comments", for: .normal)
        button.setTitleColor(UIColor.theme.lineColor, for: .normal)
        button.setTitleColor(UIColor.theme.secondaryText, for: .highlighted)
        return button
    }()
    
    private let likeCount: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.sizeToFit()
        return label
    }()
    
    private let likeButton: UIButton = {
        
        let button = UIButton()
        button.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        button.tintColor = .label
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        return button
        
    }()
    
    private let line: UIView = {
        let line = UIView()
        line.backgroundColor = .secondarySystemBackground
        return line
    }()
    
    private var profile: ProfileButton!
    
    private let followButton = Button(text: "Follow", color: UIColor.theme.blueColor)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setPost(post: Post) {
        profile = ProfileButton(image: post.user.profileImage, username: post.user.username)
        let result = String(format: "%ld %@", locale: Locale.current, post.likes, "")
        likeCount.text = result
        
        var liked: Bool = false
        likeButton.addAction(UIAction() { _ in
            if !liked {
                liked = true
                self.likeButton.tintColor = UIColor.theme.blueColor
                self.likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            } else {
                liked = false
                self.likeButton.tintColor = .label
                self.likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            }
        }, for: .touchUpInside)
        
        titleLabel.text = post.title
        addSubview(commentsButton)
        addSubview(titleLabel)
        imageView.image = post.image
        addSubview(imageView)
        addSubview(likeButton)
        addSubview(followButton)
        addSubview(profile)
        addSubview(likeCount)
        addSubview(line)
        addConstraints()
    }
    
    
    private func addConstraints() {
        
        imageView.edgesToSuperview(excluding: .bottom)
        imageView.heightToWidth(of: self, multiplier: 9/16 )
        imageView.widthToSuperview()
        
        titleLabel.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        titleLabel.topToBottom(of: imageView, offset: 10)
        
        likeButton.topToBottom(of: titleLabel, offset: 10)
        likeButton.trailingToSuperview(offset: 10)
        likeButton.height(32)
        likeButton.width(32)
        
        profile.leadingToSuperview(offset: 5)
        profile.topToBottom(of: titleLabel, offset: 5)
        profile.widthToSuperview(multiplier: 0.4)
        
        likeCount.trailingToLeading(of: likeButton, offset: -5)
        likeCount.topToBottom(of: titleLabel, offset: 15)
        
        followButton.topToBottom(of: titleLabel, offset: 5)
        followButton.trailingToLeading(of: likeCount, offset: -10)
        followButton.height(50)
        followButton.width(UIScreen.main.bounds.width / 4)
        
        commentsButton.bottomToTop(of: line, offset: -5)
        commentsButton.leadingToSuperview(offset: 5)
        
        line.horizontalToSuperview()
        line.height(1)
        line.bottomToSuperview()
        
    }
    
}
