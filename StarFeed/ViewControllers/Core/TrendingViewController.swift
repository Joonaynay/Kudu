//
//  ViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit



class TrendingViewController: UIViewController {
    
    private let titleBar = TitleBar(title: "Trending", backButton: false)
    
    private var stackView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        titleBar.vc = self
    }
    
    private func setupView() {
        // View
        view.backgroundColor = .systemBackground
        
        // Title Bar
        view.addSubview(titleBar)
        
        // Post
        let postView = PostView(post: Post(title: "Title", image: UIImage(systemName: "person.circle.fill")!))
        stackView.stack([postView])
        view.addSubview(stackView)

    }
    
    
 
    private func setupConstraints() {        
        
        titleBar.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        titleBar.height(70)
        
        stackView.edgesToSuperview(excluding: .top)        
        stackView.widthToSuperview()
        stackView.topToBottom(of: titleBar)

        
    }
    
}

