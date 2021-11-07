//
//  SubjectPostViewController.swift
//  Kudu
//
//  Created by Forrest Buhler on 10/15/21.
//

import UIKit
import FirebaseFirestore

class SubjectPostViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private let fb = FirebaseModel.shared
    
    private let titleBar: TitleBar
    private let collectionView = CustomCollectionView()
    
    public var lastDoc: QueryDocumentSnapshot?
    
    public var posts = [Post]()
    
    private let subject: Subject
    
    private let noPostsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        return label
    }()
    
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
        loadSubjectPosts(lastDoc: self.lastDoc) { [weak self] last in
            guard let self = self else { return }
            if let last = last {
                self.lastDoc = last
            }
            self.collectionView.reloadData()
            if self.posts.isEmpty {
                self.noPostsLabel.text = "No posts available."
            }
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
        collectionView.refreshControl?.addAction(UIAction() { [weak self] _ in
            guard let self = self else { return }
            if !self.collectionView.bottomRefresh.isLoading {
                self.posts = [Post]()
                self.loadSubjectPosts(lastDoc: nil) { [weak self] last in
                    guard let self = self else { return }
                    if let last = last {
                        self.lastDoc = last
                    }
                    if self.posts.isEmpty {
                        self.noPostsLabel.text = "No posts available."
                    }
                    self.collectionView.reloadData()
                    self.collectionView.refreshControl?.endRefreshing()
                }
            } else {
                self.collectionView.refreshControl?.endRefreshing()
            }
        }, for: .valueChanged)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        view.addSubview(collectionView.bottomRefresh)
        view.addSubview(noPostsLabel)
    }
    
    private func setupConstraints() {
        collectionView.horizontalToSuperview()
        collectionView.topToBottom(of: titleBar)
        collectionView.bottomToTop(of: collectionView.bottomRefresh)
        
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
        if posts.count >= indexPath.row + 1 {
            cell.setupView(post: posts[indexPath.row])
        }
        cell.vc = self
        self.noPostsLabel.text = ""
        return cell
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10.0 && !self.collectionView.refreshControl!.isRefreshing {
            
            if !collectionView.bottomRefresh.isLoading {
                self.collectionView.bottomRefresh.start()
                self.loadSubjectPosts(lastDoc: self.lastDoc) { [weak self] last in
                    if let last = last {
                        self?.lastDoc = last
                    }
                    self?.noPostsLabel.text = "No posts available."
                    self?.collectionView.bottomRefresh.stop()
                    self?.collectionView.reloadData()
                }
            }
        }
    }
    
    func loadSubjectPosts(lastDoc: QueryDocumentSnapshot?, completion: @escaping (QueryDocumentSnapshot?) -> Void) {
        let db: Query
        if let lastDoc = lastDoc {
            db = Firestore.firestore().collection("posts")
                .order(by: "date", descending: true)
                .whereField("subjects", arrayContains: self.subject.name)
                .limit(to: 10)
                .start(afterDocument: lastDoc)
        } else {
            db = Firestore.firestore().collection("posts")
                .order(by: "date", descending: true)
                .whereField("subjects", arrayContains: self.subject.name)
                .limit(to: 10)
        }
        
        db.getDocuments { [weak self] query, error in
            guard let self = self else { return }
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
