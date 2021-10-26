//
//  CommentView.swift
//  StarFeed
//
//  Created by Wendy Buhler on 10/23/21.
//

import UIKit

class CommentView: UIView {
    
    var profile: ProfileButton
    
    var user: User
    
    var text: String
    
    var label: UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    var rectLine: UIView = {
       let line = UIView()
        line.backgroundColor = .secondarySystemBackground
        return line
    }()
    
    init(user: User, text: String) {
        self.profile = ProfileButton(image: user.profileImage, username: user.username)
        self.user = user
        self.text = text
        self.label.text = text
        super.init(frame: .zero)
        addSubview(label)
        addSubview(profile)
        addSubview(rectLine)
        height(to: label, offset: 50)
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addConstraints() {
        profile.topToSuperview(offset: 5)
        profile.leadingToSuperview(offset: 15)
        profile.widthToSuperview()
        
        label.topToBottom(of: profile, offset: 5)
        label.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        
        rectLine.height(1)
        rectLine.widthToSuperview()
        rectLine.bottom(to: label)
        
    }
    
}
