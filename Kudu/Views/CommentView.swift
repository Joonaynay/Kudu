//
//  CommentView.swift
//  Kudu
//
//  Created by Wendy Buhler on 10/23/21.
//

import UIKit

class CommentView: UIView {
    
    var profile: ProfileButton
    
    weak var vc: UIViewController?
    
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
        profile.addAction(UIAction() { _ in
            self.vc?.navigationController?.pushViewController(ProfileViewController(user: user), animated: true)
        }, for: .touchUpInside)
        addSubview(label)
        addSubview(profile)
        addSubview(rectLine)
        height(to: label, offset: 70)
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addConstraints() {
        profile.topToSuperview(offset: 10)
        profile.leadingToSuperview(offset: 15)
        profile.widthToSuperview()
        
        label.topToBottom(of: profile, offset: 15)
        label.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        
        rectLine.height(1)
        rectLine.widthToSuperview()
        rectLine.bottomToSuperview()
        
    }
    
}
