//
//  SearchViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit

class SearchViewController: UIViewController, UICollectionViewDataSource, UITextFieldDelegate {

    private let titleBar = TitleBar(title: "Search", backButton: false)
    
    private let searchBar = TextField(text: "Search...", image: "magnifyingglass")
    
    private let fb = FirebaseModel.shared

    private var posts = [Post]()
    private let collectionView = CollectionView()
    
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
        
        searchBar.delegate = self
        searchBar.returnKeyType = .search
        view.addSubview(searchBar)
        view.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = false
        collectionView.refreshControl = nil
        collectionView.dataSource = self
        view.addSubview(collectionView)
    }
    
    
 
    private func setupConstraints() {
        titleBar.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        titleBar.height(70)
        
        collectionView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        collectionView.topToBottom(of: searchBar, offset: 10)
        
        searchBar.topToBottom(of: titleBar, offset: 10)
        searchBar.height(50)
        searchBar.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBar.endEditing(true)
        fb.search(string: searchBar.text!) { loadedPosts in
            self.posts = loadedPosts
            self.collectionView.reloadData()
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "post", for: indexPath) as! PostView
        cell.setPost(post: self.posts[indexPath.row])
        return cell
    }
    
}
