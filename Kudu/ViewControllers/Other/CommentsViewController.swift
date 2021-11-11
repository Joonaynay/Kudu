//
//  CommentsViewController.swift
//  Kudu
//
//  Created by Wendy Buhler on 10/23/21.
//

import UIKit

class CommentsViewController: UIViewController, UITextViewDelegate {
    
    private var post: Post
    
    private let stackView = UIStackView()
    private let backButton = BackButton()
    private let scrollView = CustomScrollView()
    
    public let addCommentButton = CustomButton(text: "Post", color: UIColor.theme.blueColor)
    
    private let fb = FirebaseModel.shared
    
    private let rectangleLine: UIView = {
        let line = UIView()
        line.backgroundColor = .secondarySystemBackground
        return line
        
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = true
        textView.backgroundColor = .secondarySystemBackground
        textView.sizeToFit()
        textView.isScrollEnabled = false
        textView.textColor = .systemGray2
        textView.text = "Comment"
        return textView
    }()
    
    private let noCommentsText: UILabel = {
        let noComment = UILabel()
        noComment.textAlignment = .center
        noComment.font = UIFont.preferredFont(forTextStyle: .body)
        noComment.text = ""
        return noComment
    }()
    
    private let titleLabel: UILabel = {
        let title = UILabel()
        title.text = "Comments"
        title.textAlignment = .center
        title.font = UIFont.preferredFont(forTextStyle: .title2)
        return title
    }()
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        backButton.vc = self
        loadCommentsViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addConstraints()
    }
    
    func setupView() {
        
        // View
        view.backgroundColor = .systemBackground
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))

        
        //Title Label
        view.addSubview(titleLabel)
        
        //Line
        view.addSubview(rectangleLine)
        
        //Back button
        view.addSubview(backButton)
        
        //No Comments Text
        view.addSubview(noCommentsText)
        
        //Add Comment
        view.addSubview(textView)
        textView.delegate = self
        addCommentButton.isEnabled = false
        view.addSubview(addCommentButton)
        
        textView.font = CustomTextField(text: "", image: nil).font
        textView.textContainerInset = UIEdgeInsets(top: 14, left: 9, bottom: 14, right: 9)
        
        //ScrollView
        view.addSubview(scrollView)
        scrollView.refreshControl = nil
        scrollView.addSubview(stackView)
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        //Stack View
        stackView.axis = .vertical
        stackView.spacing = 0
        
        addCommentButton.addAction(UIAction() { [weak self] _ in
            guard let self = self else { return }
            self.fb.commentOnPost(currentPost: self.post, comment: self.textView.text!) {
                self.textView.text = ""
                self.textView.endEditing(true)
                self.loadCommentsViews()
            }
        }, for: .touchUpInside)
    }
    
    func addConstraints() {
        titleLabel.bottom(to: backButton, offset: -5)
        titleLabel.horizontalToSuperview()
        
        scrollView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        scrollView.topToBottom(of: textView, offset: 15)
        
        textView.topToBottom(of: rectangleLine, offset: 15)
        textView.leadingToSuperview(offset: 15)
        textView.height(min: 50, max: 1000, priority: .required, isActive: true)
        textView.width(view.width * (4/6))
        
        addCommentButton.topToBottom(of: rectangleLine, offset: 15)
        addCommentButton.trailingToSuperview(offset: 15)
        addCommentButton.height(50)
        addCommentButton.leadingToTrailing(of: textView, offset: 15)
        
        stackView.edgesToSuperview()
        stackView.width(view.width)
        
        rectangleLine.horizontalToSuperview()
        rectangleLine.height(1)
        rectangleLine.topToBottom(of: backButton, offset: 10)
        
        backButton.setupBackButton()
        
        if post.comments == nil {
            noCommentsText.edgesToSuperview(excluding: .top)
            noCommentsText.centerXToSuperview()
            noCommentsText.centerYToSuperview()
        }
    }
    
    func loadCommentsViews() {
        self.fb.loadComments(currentPost: self.post) { [weak self] comments in
            guard let self = self else { return }

            if let comments = comments {
                for view in self.stackView.arrangedSubviews {
                    view.removeFromSuperview()
                }
                self.noCommentsText.text = ""                
                for comment in comments {
                    let cview = CommentView(comment: comment, post: self.post)
                    cview.vc = self
                    self.stackView.addArrangedSubview(cview)
                }
            } else {
                self.noCommentsText.text = "Be the first to comment!"
            }

        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Comment"
            textView.textColor = .systemGray2
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Comment" {
            textView.text = ""
        }
        textView.textColor = .label
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if self.textView.text != "" && self.textView.text!.count <= 600 {
                self.addCommentButton.isEnabled = true
            } else {
                self.addCommentButton.isEnabled = false
        }
        if self.textView.text.count > 600 {
            let alert = UIAlertController(title: "Comment must be 600 characters or less.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
            present(alert, animated: true)
        }
    }
    
    @objc func dismissKeyboard() {
        self.textView.endEditing(true)
    }
    
}

