//
//  MenuButton.swift
//  Kudu
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit
import TinyConstraints

class TitleBar: UIView {
    
    private let auth = AuthModel.shared
    private let fb = FirebaseModel.shared
    
    weak var vc: UIViewController?
    private let backButton: UIButton?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 35)
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
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
    
    public let profileImage = UIImageView()
    
    
    init(title: String, backButton: Bool) {
        if backButton {
            let backButton = UIButton()
            backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
            backButton.contentVerticalAlignment = .fill
            backButton.contentHorizontalAlignment = .fill
            self.backButton = backButton
        } else {
            self.backButton = nil
        }
        super.init(frame: .zero)
        self.titleLabel.text = title
        self.menuButton.menu = createMenu()
        self.menuButton.setBackgroundImage(UIImage(systemName: "line.3.horizontal"), for: .normal)
        self.menuButton.imageView!.contentMode = .scaleAspectFill
        if let profileImage = fb.currentUser.profileImage {
            self.profileImage.image = profileImage
        } else {
            self.profileImage.image = UIImage(systemName: "person.circle.fill")
        }
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.masksToBounds = false
        profileImage.layer.cornerRadius = 25
        profileImage.clipsToBounds = true
        
        if backButton {
            self.backButton?.addAction(UIAction(title: "") { [weak self] _ in
                guard let self = self else { return }
                if let vc = self.vc {
                    vc.navigationController?.popViewController(animated: true)
                }
            }, for: .touchUpInside)
            self.addSubview(self.backButton!)
        }
        addSubview(menuButton)
        addSubview(profileImage)
        addSubview(titleLabel)
        addSubview(line)                
        
        addConstraints()
    }
    
    
    private func createMenu() -> UIMenu {
        let menu = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: "Profile") { [weak self] action in
                guard let self = self else { return }
                let profile = ProfileViewController(user: self.fb.currentUser)
                profile.hidesBottomBarWhenPushed = true
                self.vc?.navigationController?.pushViewController(profile, animated: true)
            },
            UIAction(title: "New Post") { [weak self] action in
                let newPost = NewPostViewController()
                newPost.hidesBottomBarWhenPushed = true
                self?.vc?.navigationController?.pushViewController(newPost, animated: true)
            },
            UIAction(title: "Sign Out") { [weak self] action in
                guard let self = self else { return }
                let alert = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Sign Out", style: .default, handler: { _ in
                    self.auth.signOut { error in
                        if error == nil {
                            
                            let loginNav = UINavigationController(rootViewController: LoginViewController())
                            loginNav.navigationBar.isHidden = true
                            loginNav.modalPresentationStyle = .fullScreen
                            loginNav.modalTransitionStyle = .flipHorizontal
                            self.vc?.present(loginNav, animated: true)
                            
                        }
                    }
                }))
                self.vc?.present(alert, animated: true)
            }
        ])
        return menu
    }
        
    
    override func didMoveToSuperview() {
        guard superview != nil else {
            return
        }
        self.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        self.height(70)
    }
        
    private func addConstraints() {
        if backButton == nil {
            titleLabel.leadingToSuperview(offset: 10)
        } else {
            backButton!.imageEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
            backButton!.height(45)
            backButton!.width(45)
            backButton!.bottomToSuperview(offset: -14)
            backButton!.leadingToSuperview()
            titleLabel.leadingToTrailing(of: backButton!)
        }
        
        titleLabel.height(50)
        titleLabel.trailingToLeading(of: profileImage, offset: -50)
        titleLabel.bottomToSuperview(offset: -10)
        
        menuButton.trailingToSuperview(offset: 10)
        menuButton.centerYToSuperview()
        menuButton.height(30)
        menuButton.width(30)
        
        profileImage.trailingToLeading(of: menuButton, offset: -10)
        profileImage.height(50)
        profileImage.width(50)
        profileImage.bottomToSuperview(offset: -10)
    
        
        line.height(1)
        line.bottomToSuperview()
        line.leadingToSuperview()
        line.trailingToSuperview()
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
