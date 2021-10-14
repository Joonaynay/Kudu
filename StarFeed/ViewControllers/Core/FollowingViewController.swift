//
//  FollowingViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit

class FollowingViewController: UIViewController {
    
    private var titleBar = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        titleBar = UIView.titleBar(image: nil, title: "Following", vc: self)
        view.backgroundColor = .systemBackground
        view.addSubview(titleBar)
    }
    
    private func setupConstraints() {
        titleBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        titleBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        titleBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }
}
