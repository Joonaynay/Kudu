//
//  SubjectPostViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/15/21.
//

import UIKit

class SubjectPostViewController: UIViewController, UICollectionViewDataSource {

    private var titleBar: TitleBar!

    private let collectionView = CollectionView()
    
    private let fb = FirebaseModel.shared


    
    let subject: Subject
    
    init(subject: Subject) {
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
    
    override func viewDidAppear(_ animated: Bool) {
        titleBar.vc = self
        if let image = fb.currentUser.profileImage {
            titleBar.menuButton.setImage(image, for: .normal)
        }    
    }
    
    private func setupView() {
        titleBar = TitleBar(title: subject.name, backButton: true)
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
            if post.subjects.contains(subject.name) {
               posts.append(post)
            }
        }
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "post", for: indexPath) as! PostView
        var posts = [Post]()
        for post in fb.posts {
            if post.subjects.contains(subject.name) {
               posts.append(post)
            }
        }
        cell.setPost(post: posts[indexPath.row])
        return cell
    }
    
}
