//
//  SearchViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit
import AlgoliaSearchClient

class SearchViewController: UIViewController, UICollectionViewDataSource, UITextFieldDelegate, UICollectionViewDelegate {
    
    private let fb = FirebaseModel.shared
    
    private let titleBar = TitleBar(title: "Search", backButton: false)
    private let collectionView = CustomCollectionView()
    
    private let searchBar = CustomTextField(text: "Search...", image: "magnifyingglass")
    private let progress = ProgressView()
    
    private let noPostsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // TitleBar
        titleBar.vc = self
        if let image = fb.currentUser.profileImage {
            titleBar.menuButton.setImage(image, for: .normal)
        }
        collectionView.reloadData()
    }
    
    private func setupView() {
        //View
        view.addSubview(titleBar)
        view.backgroundColor = .systemBackground
        
        //Search bar
        view.addSubview(searchBar)
        searchBar.returnKeyType = .search
        searchBar.delegate = self
        view.addSubview(progress)
        
        //CollectionView
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        
        view.addSubview(noPostsLabel)
    }
    
    private func setupConstraints() {
        searchBar.topToBottom(of: titleBar, offset: 10)
        searchBar.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        searchBar.height(50)
        
        collectionView.horizontalToSuperview()
        collectionView.bottomToTop(of: collectionView.bottomRefresh)
        collectionView.topToBottom(of: searchBar, offset: 10)
        
        progress.edgesToSuperview()
        view.bringSubviewToFront(progress)
        
        noPostsLabel.centerXToSuperview()
        noPostsLabel.centerYToSuperview()
        noPostsLabel.height(50)
        noPostsLabel.horizontalToSuperview()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBar.endEditing(true)
        progress.start()
        self.search(string: searchBar.text!.lowercased()) {
            self.progress.stop()
            self.collectionView.reloadData()
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var posts = [Post]()
        for post in fb.posts { if post.title.contains(searchBar.text!.lowercased()) { posts.append(post) } }
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var posts = [Post]()
        for post in fb.posts { if post.title.contains(searchBar.text!.lowercased()) { posts.append(post) } }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "post", for: indexPath) as! PostView
        cell.setupView(post: posts[indexPath.row])
        cell.vc = self
        noPostsLabel.text = ""
        return cell
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10.0 {
            
            if !collectionView.bottomRefresh.isLoading {
                self.collectionView.bottomRefresh.start()
                self.search(string: self.searchBar.text!.lowercased()) {
                    self.collectionView.bottomRefresh.stop()
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    
    func search(string: String, completion:@escaping () -> Void) {
        fb.algoliaIndex.search(queries: ["title"], strategy: .stopIfEnoughMatches, requestOptions: .none) { result in
            
        }
    }
    
}



