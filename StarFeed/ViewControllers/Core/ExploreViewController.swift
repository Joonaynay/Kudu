//
//  ViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit
import FirebaseFirestore

class ExploreViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private let fb = FirebaseModel.shared
    
    private let titleBar = TitleBar(title: "Explore", backButton: false)
    private let collectionView = CustomCollectionView()
    
    public var lastDoc: QueryDocumentSnapshot?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        self.loadExplore(lastDoc: self.lastDoc) { last in
            if let last = last {
                self.lastDoc = last
            }
            self.collectionView.reloadData()
        }
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
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.refreshControl?.addAction(UIAction() { _ in
            
            self.collectionView.refreshControl?.endRefreshing()
            
        }, for: .valueChanged)
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
        cell.setupView(post: fb.posts[indexPath.item])
        cell.vc = self
        return cell
    }
        
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height

        if maximumOffset - currentOffset <= 10.0 {
            print("loading")
            self.loadExplore(lastDoc: self.lastDoc) { last in
                if let last = last {
                    print("loaded")
                    self.lastDoc = last
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func loadExplore(lastDoc: QueryDocumentSnapshot?, completion: @escaping (QueryDocumentSnapshot?) -> Void) {
        let db = Firestore.firestore().collection("posts").limit(to: 2).order(by: "likeCount", descending: true)
        if let lastDoc = lastDoc {
            db.start(afterDocument: lastDoc).getDocuments { query, error in
                if let query = query, error == nil {
                    let group = DispatchGroup()
                    for doc in query.documents {
                        group.enter()
                        self.fb.loadPost(postId: doc.documentID) {
                            group.leave()
                        }
                    }
                    group.notify(queue: .main) {
                        completion(query.documents.last)
                    }
                }
            }
        } else {
            db.getDocuments { query, error in
                if let query = query, error == nil {
                    let group = DispatchGroup()
                    for doc in query.documents {
                        group.enter()
                        self.fb.loadPost(postId: doc.documentID) {
                            group.leave()
                        }
                    }
                    group.notify(queue: .main) {
                        completion(query.documents.last)
                    }
                }
            }
        }
        
    }
}

