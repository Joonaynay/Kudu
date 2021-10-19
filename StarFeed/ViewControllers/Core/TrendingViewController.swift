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
    
    private let loadButton = Button(text: "Load", color: UIColor.theme.blueColor)
    
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
        view.backgroundColor = .systemBackground
        collectionView.dataSource = self
        view.addSubview(collectionView)
        view.addSubview(loadButton)
        loadButton.addAction(UIAction() { _ in
            self.fb.loadPosts { completion in
                self.collectionView.reloadData()
            }
            
        }, for: .touchUpInside)
    }
    
    
 
    private func setupConstraints() {
        titleBar.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        titleBar.height(70)
        
        collectionView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        collectionView.topToBottom(of: loadButton)
        
        loadButton.topToBottom(of: titleBar)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fb.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "post", for: indexPath) as! PostView
        cell.setPost(post: fb.posts[indexPath.row])
        return cell
    }
    
}

