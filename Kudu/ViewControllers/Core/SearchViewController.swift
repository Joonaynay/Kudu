//
//  SearchViewController.swift
//  Kudu
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit
import AlgoliaSearchClient

class SearchViewController: UIViewController, UICollectionViewDataSource, UITextFieldDelegate, UICollectionViewDelegate {
    
    private let fb = FirebaseModel.shared
    
    private let titleBar = TitleBar(title: "Search", backButton: false)
    private let collectionView = CustomCollectionView()
    
    public let searchBar = CustomTextField(text: "Search...", image: "magnifyingglass")
    private let progress = ProgressView()
    
    public var posts = [Post]()
    public var pageNumber = 0
    
    private let noPostsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // TitleBar
        titleBar.vc = self
        if let image = fb.currentUser.profileImage {
            titleBar.profileImage.image = image
            
        }
        collectionView.reloadData()
    }
    
    private func setupView() {
        //View
        view.addSubview(titleBar)
        view.backgroundColor = .systemBackground
        
        //Search bar
        view.addSubview(searchBar)
        searchBar.returnKeyType = .search
        searchBar.delegate = self
        view.addSubview(progress)
        
        //CollectionView
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addAction(UIAction() { [weak self] _ in
            guard let self = self else { return }
            if !self.collectionView.bottomRefresh.isLoading {
                self.posts = [Post]()
                self.search(string: self.searchBar.text!, withPagination: false)
                self.collectionView.reloadData()
                self.collectionView.refreshControl?.endRefreshing()
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
        searchBar.topToBottom(of: titleBar, offset: 10)
        searchBar.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        searchBar.height(50)
        
        collectionView.horizontalToSuperview()
        collectionView.bottomToTop(of: collectionView.bottomRefresh)
        collectionView.topToBottom(of: searchBar, offset: 10)
        
        progress.edgesToSuperview()
        view.bringSubviewToFront(progress)
        
        noPostsLabel.centerXToSuperview()
        noPostsLabel.centerYToSuperview()
        noPostsLabel.height(50)
        noPostsLabel.horizontalToSuperview()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBar.endEditing(true)
        progress.start()
        self.search(string: searchBar.text!.lowercased(), withPagination: false)
        
        return true
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
        noPostsLabel.text = ""
        return cell
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10.0 && !self.collectionView.refreshControl!.isRefreshing {
            
            if !collectionView.bottomRefresh.isLoading {
                self.pageNumber += 1
                self.collectionView.bottomRefresh.start()
                self.search(string: self.searchBar.text!.lowercased(), withPagination: true)
            }
        }
    }
    
    
    func search(string: String, withPagination: Bool) {
        if !withPagination {
            self.pageNumber = 0
        }
        
        let query = Query(string).set(\.page, to: self.pageNumber)
        
        fb.algoliaIndex.search(query: query, requestOptions: .none) { [weak self] result in
            guard let self = self else { return }
            if case .success(let response) = result {
                let group = DispatchGroup()
                if !withPagination {
                    self.posts = [Post]()
                }
                for hit in response.hits {
                    group.enter()
                    self.fb.loadPost(postId: "\(hit.objectID)") {
                        group.leave()
                        if let post = self.fb.posts.first(where: { post in post.id == "\(hit.objectID)" }) {
                            self.posts.append(post)
                        }
                    }
                }
                group.notify(queue: .main) {
                    self.progress.stop()
                    if self.collectionView.bottomRefresh.isLoading {
                        self.collectionView.bottomRefresh.stop()
                    }
                    if self.posts.isEmpty {
                        self.noPostsLabel.text = "No search results."
                    }
                    self.collectionView.reloadData()
                }
            } else {
                self.progress.stop()
                if self.collectionView.bottomRefresh.isLoading {
                    self.collectionView.bottomRefresh.stop()
                }
                self.collectionView.reloadData()
            }
        }
    }
}



