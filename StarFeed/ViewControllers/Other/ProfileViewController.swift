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
        return username
        
    }()
    
    //Edit Profile || Follow Button
    let button = Button(text: "Edit Profile")

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
        
        // StackView
        stackView.stack([profileImage, username, button], axis: .vertical, width: nil, height: nil, spacing: 20)
        
        // ScrollView
        scrollView.addSubview(stackView)
        view.addSubview(scrollView)
        
    }
    

    private func setupConstraints() {
        
        profileImage.height(50)
        
        scrollView.edgesToSuperview(excluding: .top)
        scrollView.topToBottom(of: backButton)
        
        stackView.edgesToSuperview(insets: TinyEdgeInsets(top: 0, left: 50, bottom: 0, right: -50))
        stackView.width(view.width - 100)
    }
}
