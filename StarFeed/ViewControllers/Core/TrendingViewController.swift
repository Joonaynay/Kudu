//
//  ViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit



class TrendingViewController: UIViewController {
    
    private var titleBar: TitleBar!
    
    private var stackView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        // View
        view.backgroundColor = .systemBackground
        
        // Title Bar
        let bar = TitleBar(title: "Trending", backButton: false)
        bar.vc = self
        self.titleBar = bar
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

