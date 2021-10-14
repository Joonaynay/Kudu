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
        titleBar = TitleBar(title: "Following", vc: self)
        view.backgroundColor = .systemBackground
    }
    
    private func setupConstraints() {

    }
}
