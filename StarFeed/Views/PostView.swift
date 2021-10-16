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
        return titleLabel
    }()
    
    private let imageView: UIImageView = {
       
        let image = UIImageView()
        return image
        
    }()
    
    private let likeButton: UIButton = {
        
        let button = UIButton()
        button.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        button.tintColor = .label
        return button
        
    }()        
    
    init(post: Post) {
        super.init(frame: .zero)        
        titleLabel.text = post.title
        addSubview(titleLabel)
        
        imageView.image = post.image
        addSubview(imageView)
        
        addSubview(likeButton)
        
        addConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addConstraints() {
        
        imageView.edgesToSuperview(excluding: .bottom)
        imageView.heightToWidth(of: self, multiplier: 9/16 )
        imageView.widthToSuperview()
        
        titleLabel.horizontalToSuperview()
        titleLabel.topToBottom(of: imageView)
        likeButton.topToBottom(of: titleLabel)
    }
    
}
