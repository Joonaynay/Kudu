//
//  PostView.swift
//  StarFeed
//
//  Created by Wendy Buhler on 10/14/21.
//

import UIKit

class PostView: UIView {
    
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
    
    private let likeButton: UIButton = {
        
        let button = UIButton()
        button.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        button.tintColor = .label
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        return button
        
    }()
    
    private let profileImage: UIButton = {
        
        let button = UIButton()
        button.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
        button.tintColor = .label
        button.imageView?.contentMode = .scaleAspectFill
        button.setTitle("Username", for: .normal)
        button.setTitleColor(.label, for: .normal)
        return button
        
    }()
    
    private let followButton = Button(text: "Follow", color: UIColor.theme.blueColor)
    
    init(post: Post) {
        super.init(frame: .zero)        
        titleLabel.text = post.title
        addSubview(titleLabel)
        imageView.image = post.image
        addSubview(imageView)
        addSubview(likeButton)
        addSubview(followButton)
        addSubview(profileImage)
        addConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addConstraints() {
        
        imageView.edgesToSuperview(excluding: .bottom)
        imageView.heightToWidth(of: self, multiplier: 9/16 )
        imageView.widthToSuperview()
        
        titleLabel.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        titleLabel.topToBottom(of: imageView, offset: 10)
        
        likeButton.topToBottom(of: titleLabel)
        likeButton.trailingToSuperview(offset: 10)
        likeButton.height(32)
        likeButton.width(32)
        
        profileImage.leadingToSuperview(offset: 10)
        profileImage.topToBottom(of: titleLabel)
        profileImage.height(40)
        
        followButton.bottomToTop(of: likeButton)
        followButton.trailingToSuperview(offset: 10)
        followButton.height(50)
    }
    
}
