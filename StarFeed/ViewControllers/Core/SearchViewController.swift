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
    
    private let noSearchResults: UILabel = {
        
       let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.textAlignment = .center
        return label
    }()
            
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "24HrsAlert") {
            let alert = UIAlertController(title: "Please allow up to 24 hours for your post to be uploaded.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            UserDefaults.standard.set(false, forKey: "24HrsAlert")
        }
        
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
        
        // No results label.
        view.addSubview(noSearchResults)

    }
 
    private func setupConstraints() {
        titleBar.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        titleBar.height(70)
        
        scrollView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        scrollView.topToBottom(of: searchBar, offset: 10)
        
        stackView.edgesToSuperview()
        stackView.width(view.width)
        
        noSearchResults.centerXToSuperview()
        noSearchResults.centerYToSuperview()
        noSearchResults.horizontalToSuperview()
        noSearchResults.height(50)
        
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
            if self.stackView.arrangedSubviews == [] {
                self.noSearchResults.text = "No results found."
            } else {
                self.noSearchResults.text = ""
            }
            self.progressView.stop()
        }
        return true
    }
        
    
}
