//
//  MenuButton.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit

extension UIView {
    class func titleBar(image: UIImage?, title: String, vc: UIViewController) -> UIView {
        let auth = AuthModel.shared
        
        //Menu
        let menu = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: "Profile") { action in
                let profile = ProfileViewController()
                profile.hidesBottomBarWhenPushed = true
                vc.navigationController?.pushViewController(profile, animated: true)
            },
            UIAction(title: "New Post") { action in
                let newPost = NewPostViewController()
                newPost.hidesBottomBarWhenPushed = true
                vc.navigationController?.pushViewController(newPost, animated: true)
            },
            UIAction(title: "Sign Out") { action in
                let alert = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Sign Out", style: .default, handler: { _ in
                    auth.signOut(vc: vc)
                }))
                vc.present(alert, animated: true)
            }
        ])
        
        //Title
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 35)
        titleLabel.textColor = .label
        
        
        //Button
        let button = UIButton()
        button.setBackgroundImage(image == nil ? UIImage(systemName: "person.circle.fill") : image, for: .normal)
        button.showsMenuAsPrimaryAction = true
        button.menu = menu
        button.translatesAutoresizingMaskIntoConstraints = false
        
        //hStack
        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.frame = CGRect(x: 15, y: 0, width: UIScreen.main.bounds.width - 20, height: (UIScreen.main.bounds.height / 6.6) - 20)
        hStack.spacing = 0
        hStack.alignment = .bottom
        hStack.distribution = .fill
        hStack.addArrangedSubview(titleLabel)
        hStack.addArrangedSubview(button)
        
        //ContentView
        let hContentView = UIView()
        hContentView.addSubview(hStack)
             
        //Line
        let line = UIView()
        line.backgroundColor = .systemGray5
        line.translatesAutoresizingMaskIntoConstraints = false
        
        //vStack
        let vStack = UIStackView(arrangedSubviews: [hContentView, line])
        vStack.axis = .vertical
        vStack.alignment = .fill
        vStack.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 6.6)
        vStack.spacing = 0
        vStack.distribution = .fill
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        //Constraints
        vStack.addConstraints(hStack.constraints)
        button.bottomAnchor.constraint(equalTo: vStack.bottomAnchor, constant: -10).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: vStack.bottomAnchor, constant: -10).isActive = true
        button.heightAnchor.constraint(equalTo: vStack.heightAnchor, multiplier: 0.45).isActive = true
        button.widthAnchor.constraint(equalTo: vStack.heightAnchor, multiplier: 0.45).isActive = true
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        line.widthAnchor.constraint(equalTo: vStack.widthAnchor).isActive = true
        line.bottomAnchor.constraint(equalTo: vStack.bottomAnchor).isActive = true
        line.leadingAnchor.constraint(equalTo: vStack.leadingAnchor).isActive = true
        line.trailingAnchor.constraint(equalTo: vStack.trailingAnchor).isActive = true
        
        return vStack
        
    }
}
