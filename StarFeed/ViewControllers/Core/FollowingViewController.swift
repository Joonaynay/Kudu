//
//  FollowingViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit
import FirebaseFirestore

class FollowingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private let fb = FirebaseModel.shared
    
    private let titleBar = TitleBar(title: "Following", backButton: false)
    private let collectionView = CustomCollectionView()
    
    public var lastDoc: QueryDocumentSnapshot?
    
    public var posts = [Post]()
    
    private let noPostsLabel: UILabel = {
        let label = UILabel()
        label.text = "No posts available."
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        self.collectionView.bottomRefresh.start()
        loadFollowing(lastDoc: self.lastDoc) { last in
            if let last = last {
                self.lastDoc = last
            }
            self.collectionView.reloadData()
            self.collectionView.bottomRefresh.stop()
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
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addAction(UIAction() { _ in
            self.posts = [Post]()
            if !self.collectionView.bottomRefresh.isLoading {
                self.loadFollowing(lastDoc: nil) { last in
                    if let last = last {
                        self.lastDoc = last
                    }
                    self.collectionView.reloadData()
                    self.collectionView.refreshControl?.endRefreshing()
                }
            } else {
                self.collectionView.refreshControl?.endRefreshing()
            }
            
        }, for: .valueChanged)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        view.addSubview(collectionView.bottomRefresh)
        view.addSubview(noPostsLabel)
    }
    
    private func setupConstraints() {
        collectionView.horizontalToSuperview()
        collectionView.bottomToTop(of: collectionView.bottomRefresh)
        collectionView.topToBottom(of: titleBar)
        
        noPostsLabel.centerXToSuperview()
        noPostsLabel.centerYToSuperview()
        noPostsLabel.height(50)
        noPostsLabel.horizontalToSuperview()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "post", for: indexPath) as! PostView
        cell.vc = self
        if posts.count >= indexPath.row + 1 {
            cell.setupView(post: posts[indexPath.row])
        }
        noPostsLabel.text = ""
        return cell
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10.0 && !self.collectionView.refreshControl!.isRefreshing {
            
            if !collectionView.bottomRefresh.isLoading {
                self.collectionView.bottomRefresh.start()
                self.loadFollowing(lastDoc: self.lastDoc) { last in
                    if let last = last {
                        self.lastDoc = last
                    }
                    self.collectionView.reloadData()
                    self.collectionView.bottomRefresh.stop()
                }
            }
        }
    }
    
    func loadFollowing(lastDoc: QueryDocumentSnapshot?, completion: @escaping (QueryDocumentSnapshot?) -> Void) {
        guard !self.fb.currentUser.following.isEmpty else {
            completion(nil)
            return
        }
        
        let db: Query
        if let lastDoc = lastDoc {
            db = Firestore.firestore().collection("posts")
                .order(by: "date", descending: true)
                .whereField("uid", in: self.fb.currentUser.following)
                .limit(to: 10)
                .start(afterDocument: lastDoc)
        } else {
            db = Firestore.firestore().collection("posts")
                .order(by: "date", descending: true)
                .whereField("uid", in: self.fb.currentUser.following)
                .limit(to: 10)
        }
        
        db.getDocuments { query, error in
            if let query = query, error == nil {
                let group = DispatchGroup()
                for doc in query.documents {
                    group.enter()
                    self.fb.loadPost(postId: doc.documentID) {
                        if let post = self.fb.posts.first(where: { posts in posts.id == doc.documentID }) {
                            self.posts.append(post)
                        }
                        group.leave()
                    }
                }
                group.notify(queue: .main) {
                    self.posts.sort { p1, p2 in
                        p1.date.timeIntervalSince1970 > p2.date.timeIntervalSince1970
                    }
                    completion(query.documents.last)
                }
            } else {
                completion(nil)
            }
        }
    }
}


