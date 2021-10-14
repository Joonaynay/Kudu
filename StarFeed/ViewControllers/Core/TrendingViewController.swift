//
//  ViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit



class TrendingViewController: UIViewController {
    
    private var titleBar = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        // View
        view.backgroundColor = .systemBackground
        
        // Title Bar
        titleBar = UIView.titleBar(image: nil, title: "Trending", vc: self)
        view.addSubview(titleBar)
        

    }
 
    private func setupConstraints() {
        
        titleBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        titleBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        titleBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }
    
    @objc private func didTapButton() {
    }
}

