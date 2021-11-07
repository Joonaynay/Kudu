//
//  ProfileButton.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/16/21.
//

import UIKit

class ProfileButton: UIButton {
    
    public let usernameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    public let profileImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    
    init(image: UIImage?, username: String) {
        super.init(frame: .zero)
        if let image = image {
            profileImage.image = image
            profileImage.layer.masksToBounds = false
            profileImage.layer.cornerRadius = 20
            profileImage.clipsToBounds = true
        } else {
            profileImage.image = UIImage(systemName: "person.circle.fill")
            profileImage.layer.masksToBounds = false
            profileImage.layer.cornerRadius = 20
            profileImage.clipsToBounds = true
        }
        profileImage.contentMode = .scaleAspectFill
        usernameLabel.text = username
        addSubview(profileImage)
        addSubview(usernameLabel)
        tintColor = .label
        addConstraints()
    }
    
    override var isHighlighted: Bool {
        didSet {
            if state == .highlighted {
                usernameLabel.textColor = .secondaryLabel
                
                profileImage.tintColor = UIColor.theme.blueTintColor
                
            } else {
                usernameLabel.textColor = .label
                profileImage.tintColor = nil
            }
        }
    }
    
    func addConstraints() {
        profileImage.leadingToSuperview()
        profileImage.centerYToSuperview()
        profileImage.height(40)
        profileImage.width(40)
        
        usernameLabel.leadingToTrailing(of: profileImage, offset: 5)
        usernameLabel.centerYToSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
