//
//  FollowingViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit

class FollowingViewController: UIViewController, UICollectionViewDataSource {

    private let titleBar = TitleBar(title: "Following", backButton: false)

    private let collectionView = CollectionView()
    
    private let fb = FirebaseModel.shared

    
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
        self.collectionView.reloadData()
    }
    
    private func setupView() {
        view.addSubview(titleBar)
        view.backgroundColor = .systemBackground
        collectionView.dataSource = self
        view.addSubview(collectionView)
    }
    
    
 
    private func setupConstraints() {
        titleBar.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        titleBar.height(70)
        
        collectionView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        collectionView.topToBottom(of: titleBar)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var posts = [Post]()
        for post in fb.posts {
            if fb.currentUser.following.contains(post.user.id) {
                posts.append(post)
            }
        }
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "post", for: indexPath) as! PostView
        var posts = [Post]()
        for post in fb.posts {
            if fb.currentUser.following.contains(post.user.id) {
                posts.append(post)
            }
        }
        cell.setPost(post: posts[indexPath.row])
        return cell
    }
    
}
