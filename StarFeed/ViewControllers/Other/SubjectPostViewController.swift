//
//  SubjectPostViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/15/21.
//

import UIKit

class SubjectPostViewController: UIViewController, UICollectionViewDataSource {

    private let fb = FirebaseModel.shared

    private let titleBar: TitleBar
    private let collectionView = CustomCollectionView()
    
    private let subject: Subject
    
    init(subject: Subject) {
        self.titleBar = TitleBar(title: subject.name, backButton: true)
        self.subject = subject
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        for post in fb.posts { if post.subjects.contains(subject.name) { posts.append(post) } }
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var posts = [Post]()
        for post in fb.posts { if post.subjects.contains(subject.name) { posts.append(post) } }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "post", for: indexPath) as! PostView
        cell.setupView(post: posts[indexPath.row])
        cell.vc = self
        return cell
    }
}
