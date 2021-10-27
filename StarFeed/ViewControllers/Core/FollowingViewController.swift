//
//  FollowingViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit



class FollowingViewController: UIViewController {
    
    private let fb = FirebaseModel.shared
    
    private let titleBar = TitleBar(title: "Following", backButton: false)
    
    private let scrollView = CustomScrollView()
    private var stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        reload()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        titleBar.vc = self
        if let image = fb.currentUser.profileImage {
            titleBar.menuButton.setImage(image, for: .normal)
        }
        reload()
    }
    
    private func setupView() {
        //View
        view.addSubview(titleBar)
        view.backgroundColor = .systemBackground
        
        //Scroll View
        scrollView.refreshControl?.addAction(UIAction() { _ in
            self.scrollView.refreshControl?.endRefreshing()
        }, for: .valueChanged)
        view.addSubview(scrollView)
        
        //StackView
        stackView.axis = .vertical
        scrollView.addSubview(stackView)
        
    }
    
    private func reload() {
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        for pview in fb.posts {
            if fb.currentUser.following.contains(pview.post.uid) {
                pview.vc = self
                stackView.addArrangedSubview(pview)
            }
        }
    }
    
    
    private func setupConstraints() {
        titleBar.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        titleBar.height(70)
        
        scrollView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        scrollView.topToBottom(of: titleBar)
        
        stackView.edgesToSuperview()
        stackView.width(view.width)
        
        
    }
    
    
}
