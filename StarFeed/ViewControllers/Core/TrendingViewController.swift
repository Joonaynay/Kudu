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
        titleBar = TitleBar(title: "Trending", vc: self)
        let postView = PostView(post: Post(title: "Title", image: UIImage(systemName: "person.circle.fill")!), vc: self)
        stackView.stack([postView])
        view.addSubview(stackView)
                

    }
 
    private func setupConstraints() {
        
        stackView.edgesToSuperview(excluding: .top)
        stackView.topToBottom(of: titleBar)
        stackView.widthToSuperview()
        
    }
    
    @objc private func didTapButton() {
    }
}

