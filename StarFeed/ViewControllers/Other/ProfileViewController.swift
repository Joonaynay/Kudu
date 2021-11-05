//
//  ProfileViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/12/21.
//

import UIKit
import TinyConstraints
import FirebaseFirestore

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private let fb = FirebaseModel.shared
    
    private var backButton = BackButton()
    private let collectionView = CustomCollectionView()
    
    public var posts = [Post]()
    public var lastDoc: QueryDocumentSnapshot?
    
    private let infoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
        button.tintColor = UIColor.theme.accentColor
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        return button
    }()
    
    private var user: User
    
    init(user: User) {
        self.user = user
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
        backButton.vc = self
        
        if self.user.followers == [] && self.user.posts == [] {
            
            //Get index of user
            guard let index = self.fb.users.firstIndex(where: { users in
                users.id == user.id
            }) else { return }
            
            fb.db.getDoc(collection: "users", id: user.id) { doc in
                let followers = doc?.get("followers") as! [String]
                let posts = doc?.get("posts") as! [String]
                
                self.fb.users[index].followers = followers
                self.fb.users[index].posts = posts
                self.user = self.fb.users[index]
                self.collectionView.reloadData()
                let menu = UIMenu(title: "", image: nil, options: .displayInline, children: [
                    UIAction(title: "Followers: \(self.user.followers.count)", image: UIImage(systemName: "person"), handler: { _ in }),
                    UIAction(title: "Posts: \(self.user.posts.count)", image: UIImage(systemName: "camera"), handler: { _ in })
                ])
                self.infoButton.menu = menu
            }
        }
        
        if !collectionView.bottomRefresh.isLoading {
            self.loadProfile(lastDoc: self.lastDoc) { last in
                if let last = last {
                    self.lastDoc = last
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    
    private func setupView() {
        
        // View
        view.backgroundColor = .systemBackground
        
        // Back Button
        view.addSubview(backButton)
        backButton.setupBackButton()
        
        // Info Button
        let menu = UIMenu(title: "", image: nil, options: .displayInline, children: [
            UIAction(title: "Followers: \(user.followers.count)", image: UIImage(systemName: "person"), handler: { _ in }),
            UIAction(title: "Posts: \(user.posts.count)", image: UIImage(systemName: "camera"), handler: { _ in })
        ])
        infoButton.menu = menu
        infoButton.showsMenuAsPrimaryAction = true
        
        view.addSubview(infoButton)
        
        
        //CollectionView
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addAction(UIAction() { _ in
            if !self.collectionView.bottomRefresh.isLoading {
                self.posts = [Post]()
                self.loadProfile(lastDoc: nil) { last in
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
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView.bottomRefresh)
        collectionView.register(ProfileView.self, forCellWithReuseIdentifier: "profile")
        
    }
    
    
    private func setupConstraints() {
        
        infoButton.topToSuperview(offset: 21, usingSafeArea: true)
        infoButton.trailingToSuperview(offset: 12)
        infoButton.height(23)
        infoButton.width(23)
        
        
        collectionView.horizontalToSuperview()
        collectionView.bottomToTop(of: collectionView.bottomRefresh)
        collectionView.topToBottom(of: backButton)
        collectionView.width(to: view)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.posts.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell
        if indexPath.row == 0 {
            let profileCell = collectionView.dequeueReusableCell(withReuseIdentifier: "profile", for: indexPath) as! ProfileView
            profileCell.vc = self
            profileCell.setupCell(user: self.user)
            cell = profileCell
        } else {
            let postCell = collectionView.dequeueReusableCell(withReuseIdentifier: "post", for: indexPath) as! PostView
            postCell.vc = self
            if posts.count >= indexPath.row {
                postCell.setupView(post: posts[indexPath.row - 1])
            }
            cell = postCell
        }
        
        return cell
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10.0 && !self.collectionView.refreshControl!.isRefreshing {
            
            if !collectionView.bottomRefresh.isLoading {
                self.collectionView.bottomRefresh.start()
                self.loadProfile(lastDoc: self.lastDoc) { last in
                    if let last = last {
                        self.lastDoc = last
                    }
                    self.collectionView.bottomRefresh.stop()
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func loadProfile(lastDoc: QueryDocumentSnapshot?, completion: @escaping (QueryDocumentSnapshot?) -> Void) {
        let db = Firestore.firestore().collection("posts")
            .order(by: "date", descending: true)
            .whereField("uid", isEqualTo: self.user.id)
            .limit(to: 10)
        
        if let lastDoc = lastDoc {
            db.start(afterDocument: lastDoc).getDocuments { query, error in
                if let query = query, error == nil {
                    let group = DispatchGroup()
                    for doc in query.documents {
                        group.enter()
                        self.fb.loadPost(postId: doc.documentID) {
                            group.leave()
                            if let post = self.fb.posts.first(where: { posts in posts.id == doc.documentID }) {
                                self.posts.append(post)
                            }
                        }
                    }
                    group.notify(queue: .main) {
                        completion(query.documents.last)
                    }
                } else {
                    completion(nil)
                }
            }
        } else {
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
                        completion(query.documents.last)
                    }
                } else {
                    completion(nil)
                }
            }
        }
    }
}

class ProfileView: UICollectionViewCell {
    
    private let fb = FirebaseModel.shared
    weak var vc: UIViewController?
    
    //Profile Image
    private let profileImage: UIButton = {
        let button = UIButton()
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.isEnabled = false
        return button
    }()
    private lazy var profileImageAction: UIAction = {
        let action = UIAction() { _ in
            self.vc?.navigationController?.pushViewController(ProfilePictureViewController(showBackButton: true), animated: true)
        }
        return action
    }()
    
    //Edit Profile || Follow Button
    private let editProfileButton = CustomButton(text: "", color: UIColor.theme.blueColor)
    private lazy var editProfileButtonAction: UIAction = {
        let action = UIAction() { _ in
            let editProfile = EditProfileViewController()
            editProfile.vc = self.vc
            self.vc?.present(editProfile, animated: true)
        }
        return action
    }()
    
    private lazy var followButtonAction: UIAction = {
        let action = UIAction() { _ in
            self.fb.followUser(followUser: self.user!) {
                self.editProfileButton.label.text = self.fb.currentUser.following.contains(self.user!.id) ? "Unfollow" : "Follow"
                if let superview = self.superview as? CustomCollectionView {
                    superview.reloadData()
                }
            }
        }
        return action
    }()

    
    // Username Label
    public let username: UILabel = {
        let username = UILabel()
        username.textAlignment = .center
        return username
    }()
    
    private var user: User?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(profileImage)
        contentView.addSubview(username)
        contentView.addSubview(editProfileButton)
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupCell(user: User) {
        self.user = user
        //Username
        username.text = user.username
        
        //Set followbutton text
        if fb.currentUser.id != user.id {
            //Add the follow button
            self.editProfileButton.label.text = self.fb.currentUser.following.contains(user.id) ? "Unfollow" : "Follow"
            
        }
        
        //Profile Image
        if let image = user.profileImage {
            profileImage.setImage(image, for: .normal)
            profileImage.setImage(image, for: .disabled)
        } else {
            profileImage.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
            profileImage.setImage(UIImage(systemName: "person.circle.fill"), for: .disabled)
        }
        profileImage.imageView!.contentMode = .scaleAspectFill
        profileImage.imageView!.layer.masksToBounds = false
        profileImage.imageView!.layer.cornerRadius = 75
        profileImage.imageView!.clipsToBounds = true
        
        if fb.currentUser.id == user.id {
            profileImage.isEnabled = true
            profileImage.addAction(profileImageAction, for: .touchUpInside)
        }
        
        //Button
        if fb.currentUser.id == user.id {
            editProfileButton.label.text = "Edit Profile"
            editProfileButton.addAction(editProfileButtonAction, for: .touchUpInside)
        } else {
            editProfileButton.addAction(followButtonAction, for: .touchUpInside)
        }
    }
    
    override func prepareForReuse() {
        //Remove actions
        profileImage.removeAction(profileImageAction, for: .touchUpInside)
        editProfileButton.removeAction(editProfileButtonAction, for: .touchUpInside)
        editProfileButton.removeAction(followButtonAction, for: .touchUpInside)
        
        username.text = nil
        editProfileButton.label.text = nil
    }
    
    private func addConstraints() {
        profileImage.height(150)
        profileImage.width(150)
        profileImage.centerXToSuperview()
        profileImage.topToSuperview(offset: 25)
        
        username.topToBottom(of: profileImage, offset: 20)
        username.centerXToSuperview()
        username.horizontalToSuperview(insets: TinyEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        
        editProfileButton.height(50)
        editProfileButton.width(150)
        editProfileButton.centerXToSuperview()
        editProfileButton.topToBottom(of: username, offset: 30)
        
    }
}
