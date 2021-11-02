//
//  FollowingViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit

class FollowingViewController: UIViewController, UICollectionViewDataSource {

    private let fb = FirebaseModel.shared

    private let titleBar = TitleBar(title: "Following", backButton: false)
    private let collectionView = CustomCollectionView()
    
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
        
        //CollectionView
        collectionView.dataSource = self
        collectionView.refreshControl?.addAction(UIAction() { _ in
            
                self.collectionView.refreshControl?.endRefreshing()
                self.collectionView.reloadData()
            
        }, for: .valueChanged)
        view.addSubview(collectionView)
    }
 
    private func setupConstraints() {
        collectionView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        collectionView.topToBottom(of: titleBar)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var posts = [Post]()
        for post in fb.posts { if self.fb.currentUser.following.contains(post.uid) { posts.append(post) } }
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var posts = [Post]()
        for post in fb.posts { if self.fb.currentUser.following.contains(post.uid) { posts.append(post) } }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "post", for: indexPath) as! PostView
        cell.vc = self
        cell.setupView(post: posts[indexPath.row])
        return cell
    }
}


