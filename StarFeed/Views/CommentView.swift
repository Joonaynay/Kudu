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
    
    var label = UILabel()
    
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
        backgroundColor = .red
        addSubview(label)
        addSubview(profile)
        addSubview(rectLine)
        addConstraints()
        sizeToFit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addConstraints() {
        profile.topToSuperview()
        profile.leadingToSuperview()
        profile.widthToSuperview()
        
        label.topToBottom(of: profile)
        label.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        
        rectLine.height(1)
        rectLine.widthToSuperview()
        rectLine.bottomToSuperview()
        
    }
    
}
