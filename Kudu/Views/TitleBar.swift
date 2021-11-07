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
    
    
    public let menuButton: UIButton = {
        let button = UIButton()
        button.showsMenuAsPrimaryAction = true
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        return button
    }()
    
    private let arrowDownImage: UIImageView = {
       let arrow = UIImageView()
        arrow.image = UIImage(systemName: "chevron.down.circle.fill")
        arrow.tintColor = UIColor.theme.accentColor
        arrow.contentMode = .scaleToFill
        arrow.backgroundColor = .systemBackground
        arrow.layer.cornerRadius = 15
        return arrow
    }()
    
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
        if let profileImage = fb.currentUser.profileImage {
            menuButton.setImage(profileImage, for: .normal)
            menuButton.contentMode = .scaleAspectFill
            menuButton.imageView!.layer.masksToBounds = false
            menuButton.imageView!.layer.cornerRadius = 25
            menuButton.imageView!.clipsToBounds = true
        } else {
            menuButton.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
            menuButton.imageView!.layer.masksToBounds = false
            menuButton.contentMode = .scaleAspectFill
            menuButton.imageView!.layer.cornerRadius = 25
            menuButton.imageView!.clipsToBounds = true
        }
        
        menuButton.addSubview(arrowDownImage)
        
        if backButton {
            self.backButton?.addAction(UIAction(title: "") { _ in
                if let vc = self.vc {
                    vc.navigationController?.popViewController(animated: true)
                }
            }, for: .touchUpInside)
            self.addSubview(self.backButton!)
        }
        addSubview(menuButton)
        addSubview(titleLabel)
        addSubview(line)                
        
        addConstraints()
    }
    
    
    private func createMenu() -> UIMenu {
        let menu = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: "Profile") { action in
                let profile = ProfileViewController(user: self.fb.currentUser)
                profile.hidesBottomBarWhenPushed = true
                self.vc?.navigationController?.pushViewController(profile, animated: true)
            },
            UIAction(title: "New Post") { action in
                let newPost = NewPostViewController()
                newPost.hidesBottomBarWhenPushed = true
                self.vc?.navigationController?.pushViewController(newPost, animated: true)
            },
            UIAction(title: "Sign Out") { action in
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
        titleLabel.trailingToLeading(of: menuButton, offset: -50)
        titleLabel.bottomToSuperview(offset: -10)
        
        menuButton.trailingToSuperview(offset: 10)
        menuButton.height(50)
        menuButton.width(50)
        menuButton.bottomToSuperview(offset: -10)
        
        arrowDownImage.height(20)
        arrowDownImage.width(20)
        arrowDownImage.bottomToSuperview(offset: 6)
        arrowDownImage.trailingToSuperview()

        
        line.height(1)
        line.bottomToSuperview()
        line.leadingToSuperview()
        line.trailingToSuperview()
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
