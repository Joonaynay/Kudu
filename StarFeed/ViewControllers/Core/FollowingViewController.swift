//
//  FollowingViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit

class FollowingViewController: UIViewController {
    
    private let titleBar = TitleBar(title: "Following", backButton: false)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        titleBar.vc = self
    }
    
    private func setupView() {
        view.addSubview(self.titleBar)        
        view.backgroundColor = .systemBackground
    }
    
    private func setupConstraints() {
        
        titleBar.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        titleBar.height(70)

    }
}
