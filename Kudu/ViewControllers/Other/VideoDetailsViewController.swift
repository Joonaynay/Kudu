//
//  VideoDetailsViewController.swift
//  Kudu
//
//  Created by Wendy Buhler on 10/27/21.
//

import UIKit
import FirebaseAuth
import AlgoliaSearchClient

class VideoDetailsViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    weak var vc: UIViewController?
    
    private let image = UIImageView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.sizeToFit()
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        return label
    }()
    
    private let descLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.sizeToFit()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        return label
    }()
    
    private var header: UILabel {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 10, weight: .heavy)
        return label
    }
    
    private let xButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    private let scrollView = CustomScrollView()
    
    private let stackView = UIStackView()
    
    private let rectLine: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        return view
    }()
    
    private var post: Post
    
    private let editImageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "pencil.circle.fill"), for: .normal)
        button.tintColor = UIColor.theme.accentColor
        button.backgroundColor = .systemBackground
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.layer.cornerRadius = 20
        return button
        
    }()
    
    private let editTitleButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "rectangle.and.pencil.and.ellipsis"), for: .normal)
        button.tintColor = UIColor.theme.accentColor
        return button
    }()
    
    private var titleTextView: UITextView = {
        let textField = UITextView()
        textField.isEditable = true
        textField.backgroundColor = .secondarySystemBackground
        textField.sizeToFit()
        textField.isScrollEnabled = false
        textField.textColor = .systemGray2
        textField.text = "Title"
        return textField
    }()
    
    private let titleDoneButton = CustomButton(text: "Save", color: UIColor.theme.blueColor)
    
    private let editDescButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "rectangle.and.pencil.and.ellipsis"), for: .normal)
        button.tintColor = UIColor.theme.accentColor
        return button
    }()
    
    private var descTextView: UITextView = {
        let textField = UITextView()
        textField.isEditable = true
        textField.backgroundColor = .secondarySystemBackground
        textField.sizeToFit()
        textField.isScrollEnabled = false
        textField.textColor = .systemGray2
        textField.text = "Title"
        return textField
    }()
    
    private let deletePostButton: UIButton = {
       let button = UIButton()
        button.setTitle("Delete", for: .normal)
        button.setTitleColor(.secondaryLabel, for: .highlighted)
        button.setTitleColor(.red, for: .normal)
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    private let descDoneButton = CustomButton(text: "Save", color: UIColor.theme.blueColor)
    
    private let fb = FirebaseModel.shared
    
    private let auth = AuthModel.shared
    
    init(post: Post) {
        self.post = post
        self.image.image = post.image
        self.image.contentMode = .scaleAspectFill
        self.image.clipsToBounds = true
        self.descLabel.text = post.description
        self.titleLabel.text = post.title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground.withAlphaComponent(0.975)
        setupView()
        addConstraints()
    }
    
    func setupView() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        view.addSubview(scrollView)
        view.addSubview(xButton)
        scrollView.addSubview(rectLine)
        scrollView.refreshControl = nil
        scrollView.addSubview(stackView)
        scrollView.addSubview(image)
        if self.fb.currentUser.id == self.post.uid {
            scrollView.addSubview(editImageButton)
            scrollView.addSubview(editTitleButton)
            scrollView.addSubview(editDescButton)
            scrollView.addSubview(deletePostButton)
        }
        
        editImageButton.addAction(UIAction() { [weak self] _ in
            guard let self = self else { return }
            let picker = ImagePicker(mediaTypes: ["public.image"], allowsEditing: true)
            picker.delegate = self
            self.present(picker, animated: true)
            
        }, for: .touchUpInside)
        
        editTitleButton.addAction(UIAction() { [weak self] _ in
            guard let self = self else { return }
            self.view.addSubview(self.titleTextView)
            self.titleTextView.font = self.titleLabel.font
            self.titleTextView.textContainerInset = UIEdgeInsets(top: 14, left: 9, bottom: 14, right: 9)
            self.titleTextView.delegate = self
            self.titleTextView.horizontalToSuperview()
            self.titleTextView.topToBottom(of: self.image, offset: 32)
            self.titleTextView.height(min: 50, max: 1000)
            self.titleTextView.text = self.post.title
            
            self.view.addSubview(self.titleDoneButton)
            self.titleDoneButton.topToBottom(of: self.titleTextView, offset: 5)
            self.titleDoneButton.trailing(to: self.titleTextView, offset: -5)
            self.titleDoneButton.height(50)
            self.titleDoneButton.width(self.view.width / 4)
        }, for: .touchUpInside)
        
        editDescButton.addAction(UIAction() { [weak self] _ in
            guard let self = self else { return }
            self.view.addSubview(self.descTextView)
            self.descTextView.font = self.descLabel.font
            self.descTextView.textContainerInset = UIEdgeInsets(top: 14, left: 9, bottom: 14, right: 9)
            self.descTextView.delegate = self
            self.descTextView.horizontalToSuperview()
            self.descTextView.top(to: self.descLabel)
            self.descTextView.height(min: 50, max: 1000)
            self.descTextView.text = self.post.description
            
            self.view.addSubview(self.descDoneButton)
            self.descDoneButton.topToBottom(of: self.descTextView, offset: 5)
            self.descDoneButton.trailing(to: self.descTextView, offset: -5)
            self.descDoneButton.height(50)
            self.descDoneButton.width(self.view.width / 4)
            
        }, for: .touchUpInside)
        
        titleDoneButton.addAction(UIAction() { [weak self] _ in
            guard let self = self else { return }
            if self.titleTextView.text != self.post.title {
                self.fb.db.save(collection: "posts", document: self.post.id, field: "title", data: self.titleTextView.text!)
                do {
                    try self.fb.algoliaIndex.replaceObject(withID: ObjectID(stringLiteral: self.post.id), by: ["objectID": self.post.id, "title": self.titleTextView.text])
                } catch let error {
                    fatalError(error.localizedDescription)
                }
                self.post.title = self.titleTextView.text
                if let index = self.fb.posts.firstIndex(where: { post in post.id == self.post.id }) {
                    self.fb.posts[index].title = self.titleTextView.text
                }
                self.titleLabel.text = self.titleTextView.text
                if let collectionView = self.vc?.view.subviews.first(where: { view in view is CustomCollectionView }) as? CustomCollectionView {
                    collectionView.reloadData()
                }
            }
            self.titleTextView.removeFromSuperview()
            self.titleDoneButton.removeFromSuperview()
        }, for: .touchUpInside)
        
        descDoneButton.addAction(UIAction() { [weak self] _ in
            guard let self = self else { return }
            if self.descTextView.text != self.post.title {
                self.fb.db.save(collection: "posts", document: self.post.id, field: "description", data: self.descTextView.text!)
                
                self.post.description = self.descTextView.text
                if let index = self.fb.posts.firstIndex(where: { post in post.id == self.post.id }) {
                    self.fb.posts[index].description = self.descTextView.text
                }
                self.descLabel.text = self.descTextView.text
                if let collectionView = self.vc?.view.subviews.first(where: { view in view is CustomCollectionView }) as? CustomCollectionView {
                    collectionView.reloadData()
                }
            }
            self.descTextView.removeFromSuperview()
            self.descDoneButton.removeFromSuperview()
        }, for: .touchUpInside)
        
        deletePostButton.addAction(UIAction() { [weak self] _ in
            guard let self = self else { return }
            let warningAlert = UIAlertController(title: "Warning", message: "Are you sure you want to delete this post?", preferredStyle: .actionSheet)
            warningAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            warningAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                let passwordAlert = UIAlertController(title: "Please type in your password to delete this post.", message: nil, preferredStyle: .alert)
                passwordAlert.addTextField { textField in
                    textField.placeholder = "Password"
                    textField.isSecureTextEntry = true
                }
                passwordAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                passwordAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] _ in
                    guard let self = self else { return }
                    self.auth.signIn(email: Auth.auth().currentUser!.email!, password: passwordAlert.textFields!.first!.text!) { error in
                        if let error = error {
                            let errorAlert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                            errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(errorAlert, animated: true)
                        } else {
                            self.fb.deletePost(id: self.post.id)
                            switch self.vc {
                            case is ProfileViewController:
                                let vc = self.vc as! ProfileViewController
                                vc.posts = [Post]()
                                vc.loadProfile(lastDoc: nil) { last in
                                    if let last = last {
                                        vc.lastDoc = last
                                    }
                                }
                            case is FollowingViewController:
                                let vc = self.vc as! FollowingViewController
                                vc.posts = [Post]()
                                vc.loadFollowing(lastDoc: nil) { last in
                                    if let last = last {
                                        vc.lastDoc = last
                                    }
                                    
                                }
                            case is SearchViewController:
                                let vc = self.vc as! SearchViewController
                                vc.posts = [Post]()
                                vc.search(string: vc.searchBar.text!, withPagination: false)                                
                                
                            case is ExploreViewController:
                                let vc = self.vc as! ExploreViewController
                                vc.posts = [Post]()
                                vc.loadExplore(lastDoc: nil) { last in
                                    if let last = last {
                                        vc.lastDoc = last
                                    }
                                }
                                
                            case is SubjectPostViewController:
                                let vc = self.vc as! SubjectPostViewController
                                vc.posts = [Post]()
                                vc.loadSubjectPosts(lastDoc: nil) { last in
                                    if let last = last {
                                        vc.lastDoc = last
                                    }
                                }
                                
                            default:
                                return
                            }
                            if let collectionView = self.vc?.view.subviews.first(where: { view in view is CustomCollectionView }) as? CustomCollectionView {
                                collectionView.reloadData()
                            }
                            let successAlert = UIAlertController(title: "Success", message: "Successfully deleted post.", preferredStyle: .alert)
                            successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
                                self?.dismiss(animated: true)
                            }))
                            self.present(successAlert, animated: true)
                        }
                    }
                }))
                self.present(passwordAlert, animated: true)
            }))
            self.present(warningAlert, animated: true)
        }, for: .touchUpInside)
        
        let descHeader = header
        descHeader.text = "DESCRIPTION"
        
        self.xButton.addAction(UIAction() { [weak self] _ in
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descHeader)
        if descLabel.text == "" {
            descLabel.text = "No description was provided."
        }
        stackView.addArrangedSubview(descLabel)
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.setCustomSpacing(40, after: titleLabel)
        
    }
    
    func addConstraints() {
        scrollView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        scrollView.topToBottom(of: xButton, offset: 10)
        
        xButton.topToSuperview(offset: 10, usingSafeArea: true)
        xButton.height(20)
        xButton.width(20)
        xButton.trailingToSuperview(offset: 10)
        
        rectLine.height(1)
        rectLine.widthToSuperview()
        rectLine.bottom(to: titleLabel, offset: 20)
        

        
        
        if fb.currentUser.id == self.post.uid {
            editImageButton.bottom(to: image, offset: -5)
            editImageButton.trailing(to: image, offset: -5)
            editImageButton.width(30)
            editImageButton.height(30)
            scrollView.bringSubviewToFront(editImageButton)
            
            editTitleButton.bottom(to: titleLabel)
            editTitleButton.leadingToTrailing(of: titleLabel, offset: -7)
            
            editDescButton.bottom(to: descLabel)
            editDescButton.leadingToTrailing(of: descLabel, offset: -7)
            
            deletePostButton.topToBottom(of: descLabel, offset: 10)
            deletePostButton.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 30))
            deletePostButton.height(50)
        }
        
        image.topToSuperview()
        image.horizontalToSuperview()
        image.height(view.width * (9/16))
        image.width(to: view)
        
        stackView.edgesToSuperview(excluding: .top, insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 30))
        stackView.topToBottom(of: image, offset: 30)
        stackView.width(to: view, offset: -45)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if titleTextView.text.count >= 100 {
            titleDoneButton.isEnabled = false
            let alert = UIAlertController(title: "Title must be 100 characters or less.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
            present(alert, animated: true)
        } else {
            titleDoneButton.isEnabled = true
        }
        
        if descTextView.text.count >= 1000 {
            descDoneButton.isEnabled = false
            let alert = UIAlertController(title: "Description must be 1,000 characters or less.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
            present(alert, animated: true)
        } else {
            descDoneButton.isEnabled = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if titleTextView.text.isEmpty {
            titleTextView.text = "Title"
            titleTextView.textColor = .systemGray2
        }
        
        if descTextView.text.isEmpty {
            descTextView.text = "Title"
            descTextView.textColor = .systemGray2
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if titleTextView.text == "Title" {
            titleTextView.text = ""
        }
        titleTextView.textColor = .label
        
        if descTextView.text == "Title" {
            descTextView.text = ""
        }
        descTextView.textColor = .label
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.editedImage] as? UIImage {
            self.fb.storage.saveImage(path: "images", file: self.post.id, image: image)
            self.post.image = image
            if let index = self.fb.posts.firstIndex(where: { post in post.id == self.post.id }) {
                self.fb.posts[index].image = image
            }
            self.image.image = image
            self.fb.file.saveImage(image: image, id: post.id)
            if let collectionView = vc?.view.subviews.first(where: { view in view is CustomCollectionView }) as? CustomCollectionView {
                collectionView.reloadData()
            }
        }
    }
    
    @objc func dismissKeyboard() {
        self.descTextView.endEditing(true)
        self.titleTextView.endEditing(true)
    }
    
}
