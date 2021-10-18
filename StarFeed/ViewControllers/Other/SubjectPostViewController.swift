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
    
    private let auth = AuthModel.shared

    
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
        if let image = auth.currentUser.profileImage {
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
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "post", for: indexPath) as! PostView
        cell.setPost(post: Post(id: "", image: UIImage(systemName: "person.circle.fill")!, title: "", subjects: [], date: "", user: User(id: "", username: "", name: "", profileImage: nil, following: [], followers: [], posts: nil), likes: [], comments: [], movie: nil))
        return cell
    }
    
}
