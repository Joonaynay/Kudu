//
//  CommentsViewController.swift
//  StarFeed
//
//  Created by Wendy Buhler on 10/23/21.
//

import UIKit

class CommentsViewController: UIViewController {
    
    private var post: Post
    
    private let stackView = UIView()
    
    private var comments = [CommentView]()
    
    private let backButton = BackButton()
    
    private let scrollView = CustomScrollView()
    
    private let textField = CustomTextField(text: "Add a comment.", image: nil)
    
    private let addComment = CustomButton(text: "Add", color: UIColor.theme.blueColor)
    
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
        title.font = UIFont.preferredFont(forTextStyle: .title1)
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
            self.post.comments = commentsArray
            guard let postComment = self.post.comments else { return }
            for comment in postComment {
                self.comments.append(CommentView(user: comment.user, text: comment.text))
            }
            self.stackView.stack(self.comments)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addConstraints()
    }
    
    func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(rectangleLine)
        view.addSubview(backButton)
        view.addSubview(noCommentsText)
        view.addSubview(scrollView)
        scrollView.addSubview(textField)
        scrollView.addSubview(addComment)
        scrollView.addSubview(stackView)
        addComment.addAction(UIAction() { _ in
            self.fb.commentOnPost(currentPost: self.post, comment: self.textField.text!)
        }, for: .touchUpInside)
    }
    
    func addConstraints() {
        titleLabel.bottom(to: backButton, offset: 5)
        titleLabel.horizontalToSuperview()
        
        scrollView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        scrollView.topToBottom(of: rectangleLine)
        
        textField.topToBottom(of: rectangleLine, offset: 15)
        textField.leading(to: view, offset: view.width * (1/12))
        textField.height(50)
        textField.width(view.width * (4/6))
        
        addComment.topToBottom(of: rectangleLine, offset: 15)
        addComment.leftToRight(of: textField)
        addComment.trailing(to: view, offset: -view.width * (1/12))
        addComment.height(50)
        addComment.width(view.width * (1/6))
        
        stackView.topToBottom(of: textField, offset: 15)
        stackView.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        stackView.bottom(to: scrollView)
        stackView.width(to: view, offset: -30)
        
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

