//
//  ViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit



class TrendingViewController: UIViewController {
    
    private var titleBar: TitleBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        // View
        view.backgroundColor = .systemBackground
        
        // Title Bar
        titleBar = TitleBar(title: "Trending", vc: self)

    }
 
    private func setupConstraints() {

    }
    
    @objc private func didTapButton() {
    }
}

