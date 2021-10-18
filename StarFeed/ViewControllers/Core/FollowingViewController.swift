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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        titleBar.vc = self
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
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "post", for: indexPath) as! PostView
        cell.setPost(post: Post(title: "Title", image: UIImage(systemName: "person.circle.fill")!, user: User(name: "Name", username: "Username", profileImage: UIImage(systemName: "person.circle.fill")), likes: 100))
        return cell
    }
    
}
