//
//  ProfileViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/12/21.
//

import UIKit
import TinyConstraints

class ProfileViewController: UIViewController {
    
    private let scrollView = ScrollView()
    private var backButton: BackButton!
    let stackView = UIView()
    
    //Profile Image
    let profileImage = UIImageView(image: UIImage(systemName: "person.circle.fill"))
    
    // Username Label
    let username: UILabel = {
        
        let username = UILabel()
        username.text = "Username"
        username.textAlignment = .center
        return username
        
    }()
    
    //Edit Profile || Follow Button
    let button = Button(text: "Edit Profile", color: UIColor.theme.blueColor)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        
        // View
        view.backgroundColor = .systemBackground
        
        // Back Button
        backButton = BackButton(vc: self)
        view.addSubview(backButton)
        
        //Profile Image
        scrollView.addSubview(profileImage)
        
        //Username
        scrollView.addSubview(username)
        
        //Button
        scrollView.addSubview(button)
        
        //Stack View
        stackView.stack([])
        
        // ScrollView
        scrollView.addSubview(stackView)
        view.addSubview(scrollView)
        
    }
    
    
    private func setupConstraints() {
        
        profileImage.height(150)
        profileImage.width(150)
        profileImage.centerX(to: scrollView)
        profileImage.top(to: scrollView)
                
        username.topToBottom(of: profileImage, offset: 20)
        username.centerX(to: scrollView)
        username.horizontalToSuperview(insets: TinyEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
                
        button.height(50)
        button.width(150)
        button.centerX(to: scrollView)
        button.topToBottom(of: username, offset: 30)
        
        scrollView.edgesToSuperview(excluding: .top)
        scrollView.topToBottom(of: backButton)
        
        stackView.edgesToSuperview()
        stackView.width(view.width)
    }
}
