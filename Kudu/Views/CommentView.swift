//
//  CommentView.swift
//  Kudu
//
//  Created by Wendy Buhler on 10/23/21.
//

import UIKit

class CommentView: UIView {
    
    private let fb = FirebaseModel.shared
    
    var profile: ProfileButton
    
    weak var vc: UIViewController?
    
    var comment: Comment
    
    var post: Post
    
    var label: UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    var rectLine: UIView = {
       let line = UIView()
        line.backgroundColor = .secondarySystemBackground
        return line
    }()
    
    var deleteComment: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.tintColor = .label
        return button
    }()
    
    init(comment: Comment, post: Post) {
        self.comment = comment
        self.post = post
        self.profile = ProfileButton(image: comment.user.profileImage, username: comment.user.username)
        self.label.text = comment.text
        super.init(frame: .zero)
        profile.addAction(UIAction() { [weak self] _ in
            self?.vc?.navigationController?.pushViewController(ProfileViewController(user: comment.user), animated: true)
        }, for: .touchUpInside)
        if comment.user.id == fb.currentUser.id {
            addSubview(deleteComment)
            deleteComment.addAction(UIAction() { [weak self] _ in
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alert.addAction(UIAlertAction(title: "Delete Comment", style: .default, handler: { _ in
                    let checkAlert = UIAlertController(title: nil, message: "Are you sure you want to delete this comment?", preferredStyle: .alert)
                    checkAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    checkAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                        self?.fb.deleteComment(postId: post.id, comment: comment)
                        if let vc = self?.vc as? CommentsViewController {
                            vc.loadCommentsViews()
                        }
                    }))
                    self?.vc?.present(checkAlert, animated: true)
                }))
                self?.vc?.present(alert, animated: true)
            }, for: .touchUpInside)
        }
        addSubview(label)
        addSubview(profile)
        addSubview(rectLine)
        height(to: label, offset: 70)
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addConstraints() {
        profile.topToSuperview(offset: 10)
        profile.leadingToSuperview(offset: 15)
        profile.widthToSuperview()
        
        label.topToBottom(of: profile, offset: 15)
        if comment.user.id != fb.currentUser.id {
            label.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        } else {
            label.leadingToSuperview(offset: 15)
            label.trailingToLeading(of: deleteComment)
            deleteComment.trailingToSuperview(offset: 15)
            deleteComment.centerYToSuperview()
            deleteComment.height(10)
            deleteComment.width(30)
        }
        
        rectLine.height(1)
        rectLine.widthToSuperview()
        rectLine.bottomToSuperview()
        
    }
}
