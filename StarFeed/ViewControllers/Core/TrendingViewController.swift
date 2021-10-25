//
//  ViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit



class TrendingViewController: UIViewController {
    
    private let fb = FirebaseModel.shared

    private let titleBar = TitleBar(title: "Trending", backButton: false)

    private let scrollView = CustomScrollView()
    private var stackView = UIView()
    
    private var posts = [PostView]()
        
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
            self.fb.loadPosts { 
                self.scrollView.refreshControl?.endRefreshing()
                self.reload()
            }
        }, for: .valueChanged)
        view.addSubview(scrollView)
        
        //StackView
        scrollView.addSubview(stackView)

    }
    
    private func reload() {
        posts = [PostView]()
        
        for post in fb.posts {
            let pview = PostView(post: post)
            pview.vc = self
            posts.append(pview)
        }
        stackView.stack(posts)
    }
        
 
    private func setupConstraints() {
        titleBar.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        titleBar.height(70)
        
        scrollView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        scrollView.topToBottom(of: titleBar)
        
        stackView.top(to: scrollView)
        stackView.leading(to: scrollView)
        stackView.trailing(to: scrollView)
        stackView.bottom(to: scrollView)
        
        stackView.width(view.width)
        


    }
        
    
}

