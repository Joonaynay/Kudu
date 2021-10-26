//
//  CommentsViewController.swift
//  StarFeed
//
//  Created by Wendy Buhler on 10/23/21.
//

import UIKit

class CommentsViewController: UIViewController {
    
    private var post: Post
    
    private let stackView = UIStackView()
    private let backButton = BackButton()
    private let scrollView = CustomScrollView()
    private let textField = CustomTextField(text: "Add a comment.", image: nil)
    
    private let addCommentButton = CustomButton(text: "Post", color: UIColor.theme.blueColor)
    
    private let fb = FirebaseModel.shared
        
    private let rectangleLine: UIView = {
        let line = UIView()
        line.backgroundColor = .secondarySystemBackground
        return line
        
    }()
    
    private let noCommentsText: UILabel = {
       let noComment = UILabel()
        noComment.text = "Be the first one to comment!"
        noComment.textAlignment = .center
        noComment.font = UIFont.preferredFont(forTextStyle: .body)
        
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
        fb.loadComments(currentPost: post) { commentsArray in
            guard let commentsArray = commentsArray else { return }
            self.noCommentsText.text = ""
            for comment in commentsArray {
                let commentView = CommentView(user: comment.user, text: comment.text)
                self.stackView.addArrangedSubview(commentView)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addConstraints()
    }
    
    func setupView() {
        
        // View
        view.backgroundColor = .systemBackground
        
        //Title Label
        view.addSubview(titleLabel)
        
        //Line
        view.addSubview(rectangleLine)
        
        //Back button
        view.addSubview(backButton)
        
        //No Comments Text
        view.addSubview(noCommentsText)
        
        //Add Comment
        view.addSubview(textField)
        view.addSubview(addCommentButton)
        
        //ScrollView
        view.addSubview(scrollView)
        scrollView.refreshControl = nil
        scrollView.addSubview(stackView)
        
        //Stack View
        stackView.axis = .vertical
        stackView.spacing = 0
        
        addCommentButton.addAction(UIAction() { _ in
            self.fb.commentOnPost(currentPost: self.post, comment: self.textField.text!)
        }, for: .touchUpInside)
    }
    
    func addConstraints() {
        titleLabel.bottom(to: backButton, offset: -5)
        titleLabel.horizontalToSuperview()
        
        scrollView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        scrollView.topToBottom(of: textField, offset: 15)
        
        textField.topToBottom(of: rectangleLine, offset: 15)
        textField.leadingToSuperview(offset: 15)
        textField.height(50)
        textField.width(view.width * (4/6))
        
        addCommentButton.topToBottom(of: rectangleLine, offset: 15)
        addCommentButton.trailingToSuperview(offset: 15)
        addCommentButton.height(50)
        addCommentButton.leadingToTrailing(of: textField, offset: 15)
        
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
    
}

