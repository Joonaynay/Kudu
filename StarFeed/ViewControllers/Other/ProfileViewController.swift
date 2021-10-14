//
//  ProfileViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/12/21.
//

import UIKit

class ProfileViewController: UIViewController {
    
    private let scrollView = ScrollView()
    private var backButton: BackButton!

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
        let profileImage = UIImageView(image: UIImage(systemName: "person.circle.fill"))
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        
        // Username Label
        let username = UILabel()
        username.translatesAutoresizingMaskIntoConstraints = false
        username.text = "Username"
        
        //Edit Profile || Follow Button
        let button = Button(text: "Edit Profile")
        button.translatesAutoresizingMaskIntoConstraints = false
                
    }
    

    private func setupConstraints() {
        
        backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

    }
}
