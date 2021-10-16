//
//  FollowingViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit

class FollowingViewController: UIViewController {
    
    private var titleBar: TitleBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        titleBar = TitleBar(title: "Following", backButton: false)
        titleBar.vc = self
        view.addSubview(self.titleBar)
        
        view.backgroundColor = .systemBackground
    }
    
    private func setupConstraints() {
        
        titleBar.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        titleBar.height(70)

    }
}
