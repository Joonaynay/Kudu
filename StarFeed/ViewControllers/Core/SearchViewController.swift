//
//  SearchViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit

class SearchViewController: UIViewController, UITextFieldDelegate {
    
    private let fb = FirebaseModel.shared

    private let titleBar = TitleBar(title: "Search", backButton: false)
    private let searchBar = CustomTextField(text: "Search...", image: "magnifyingglass")

    private let progressView = ProgressView()
    private let scrollView = CustomScrollView()
    private var stackView = UIStackView()
            
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        titleBar.vc = self
        if let image = fb.currentUser.profileImage {
            titleBar.menuButton.setImage(image, for: .normal)
        }
    }
    
    private func setupView() {
        //View
        view.addSubview(titleBar)
        view.backgroundColor = .systemBackground
        
        //Search Bar
        searchBar.returnKeyType = .search
        searchBar.delegate = self
        view.addSubview(searchBar)
        
        //Progress View
        view.addSubview(progressView)
        
        //Scroll View
        scrollView.refreshControl = nil        
        view.addSubview(scrollView)
        
        //StackView
        stackView.axis = .vertical
        scrollView.addSubview(stackView)

    }
 
    private func setupConstraints() {
        titleBar.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        titleBar.height(70)
        
        scrollView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        scrollView.topToBottom(of: searchBar, offset: 10)
        
        stackView.edgesToSuperview()
        stackView.width(view.width)
        
        searchBar.topToBottom(of: titleBar, offset: 10)
        searchBar.height(50)
        searchBar.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        
        view.bringSubviewToFront(progressView)
        progressView.edgesToSuperview()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = searchBar.text!.lowercased()
        searchBar.endEditing(true)
        self.progressView.start()
        fb.search(string: text) {
            for view in self.stackView.arrangedSubviews {
                view.removeFromSuperview()
            }
            for post in self.fb.posts {
                if post.post.title.lowercased().contains(text) {
                    post.vc = self
                    self.stackView.addArrangedSubview(post)
                }
            }
            self.progressView.stop()
        }
        return true
    }
        
    
}
