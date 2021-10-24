//
//  SearchViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit

class SearchViewController: UIViewController {

    private let titleBar = TitleBar(title: "Search", backButton: false)
    
    private let searchBar = CustomTextField(text: "Search...", image: "magnifyingglass")
    
    private let fb = FirebaseModel.shared
    
    private let progressView = ProgressView()
    
    private var posts = [Post]()
    private let scrollView = CustomScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        titleBar.vc = self
        if let image = fb.currentUser.profileImage {
            titleBar.menuButton.setImage(image, for: .normal)
        }    
    }
    
    private func setupView() {
        view.addSubview(titleBar)
        
        searchBar.returnKeyType = .search
        view.addSubview(searchBar)
        view.backgroundColor = .systemBackground
        scrollView.refreshControl = nil

        view.addSubview(scrollView)
        view.addSubview(progressView)
    }
    
    
 
    private func setupConstraints() {
        titleBar.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        titleBar.height(70)
        
        scrollView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        scrollView.topToBottom(of: searchBar, offset: 10)
        
        searchBar.topToBottom(of: titleBar, offset: 10)
        searchBar.height(50)
        searchBar.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        
        view.bringSubviewToFront(progressView)
        progressView.edgesToSuperview()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBar.endEditing(true)
        self.progressView.start()
        fb.search(string: searchBar.text!) { loadedPosts in
            self.posts = loadedPosts
            self.progressView.stop()
        }
        return true
    }
    
}
