//
//  ViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit

class ExploreViewController: UIViewController, UICollectionViewDataSource {

    private let fb = FirebaseModel.shared

    private let titleBar = TitleBar(title: "Explore", backButton: false)
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
            self.fb.loadPosts { 
                self.collectionView.refreshControl?.endRefreshing()
                self.collectionView.reloadData()
            }
        }, for: .valueChanged)
        view.addSubview(collectionView)
    }
 
    private func setupConstraints() {
        collectionView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        collectionView.topToBottom(of: titleBar)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fb.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "post", for: indexPath) as! PostView
        cell.setupView(post: fb.posts[indexPath.row])
        cell.vc = self
        return cell
    }
}

