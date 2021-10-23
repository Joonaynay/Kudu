//
//  ViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit



class TrendingViewController: UIViewController, UICollectionViewDataSource {
    
    private let fb = FirebaseModel.shared

    private let titleBar = TitleBar(title: "Trending", backButton: false)

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
        collectionView.reloadData()
    }
    
    private func setupView() {
        //View
        view.addSubview(titleBar)
        view.backgroundColor = .systemBackground
        
        //Collection View
        collectionView.dataSource = self
        collectionView.refreshControl?.addAction(UIAction() { _ in
            self.fb.loadPosts { 
                self.collectionView.refreshControl?.endRefreshing()
                self.collectionView.reloadData()
            }
        }, for: .valueChanged)
        view.addSubview(collectionView)
                
    }
        
 
    private func setupConstraints() {
        titleBar.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        titleBar.height(70)
        
        collectionView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        collectionView.topToBottom(of: titleBar)

    }
        
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fb.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "post", for: indexPath) as! PostView
        cell.vc = self        
        cell.setPost(post: fb.posts[indexPath.row])
        return cell
    }
    
}

