//
//  MenuButton.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit
import TinyConstraints

class TitleBar: UIView {
    
    private let auth = AuthModel.shared
    
    private let vc: UIViewController
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 35)
        label.textColor = .label
        return label
    }()
    
    private let line: UIView = {
        let line = UIView()
        line.backgroundColor = .secondarySystemBackground
        return line
    }()
    
    
    private let menuButton: UIButton = {
        let button = UIButton()
        button.showsMenuAsPrimaryAction = true
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        return button
    }()
    
    init(title: String, vc: UIViewController) {
        self.vc = vc
        super.init(frame: .zero)
        titleLabel.text = title
        menuButton.menu = createMenu()
        menuButton.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
        addSubview(menuButton)
        addSubview(titleLabel)
        addSubview(line)
        vc.view.addSubview(self)
        addConstraints()
    }
    
    
    private func createMenu() -> UIMenu {
        let menu = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: "Profile") { action in
                let profile = ProfileViewController()
                profile.hidesBottomBarWhenPushed = true
                self.vc.navigationController?.pushViewController(profile, animated: true)
            },
            UIAction(title: "New Post") { action in
                let newPost = NewPostViewController()
                newPost.hidesBottomBarWhenPushed = true
                self.vc.navigationController?.pushViewController(newPost, animated: true)
            },
            UIAction(title: "Sign Out") { action in
                let alert = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Sign Out", style: .default, handler: { _ in
                    self.auth.signOut(vc: self.vc)
                }))
                self.vc.present(alert, animated: true)
            }
        ])
        return menu
    }
    
    private func addConstraints() {
        titleLabel.leadingToSuperview(offset: 10)
        titleLabel.height(50)
        titleLabel.widthToSuperview(multiplier: 0.5)
        titleLabel.bottomToSuperview(offset: -10)
        
        menuButton.trailingToSuperview(offset: 10)
        menuButton.height(50)
        menuButton.width(50)
        menuButton.bottomToSuperview(offset: -10)
        
        line.height(1)
        line.bottomToSuperview()
        line.leadingToSuperview()
        line.trailingToSuperview()
                
        top(to: vc.view.safeAreaLayoutGuide)
        leading(to: vc.view.safeAreaLayoutGuide)
        trailing(to: vc.view.safeAreaLayoutGuide)
        height(75)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
