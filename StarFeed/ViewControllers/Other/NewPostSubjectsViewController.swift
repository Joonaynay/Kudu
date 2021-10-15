//
//  NewPostSubjectsViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/14/21.
//

import UIKit
import TinyConstraints

class NewPostSubjectsViewController: UIViewController {
    
    private let scrollView = ScrollView()
    private var backButton: BackButton!
    private let stackView = TinyView()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Select up to 3 subjects that your post corrosponds with"
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    private var checkLine: UIButton {
        let button = UIButton()
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        let image = UIImage(systemName: "square")
        let tinted = image?.withRenderingMode(.alwaysTemplate)
        button.setImage(tinted, for: .normal)
        button.setTitleColor(UIColor.theme.accentColor, for: .normal)
        button.contentHorizontalAlignment = .left
        button.setTitle("Subject", for: .normal)
        return button
    }
    
    private let postButton = Button(text: "Post", color: UIColor.theme.blueColor)
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addConstraints()
    }
    
    func setupView() {
        view.addSubview(scrollView)
        view.backgroundColor = .systemBackground
        
        backButton = BackButton(vc: self)
        
        view.addSubview(titleLabel)
        
        scrollView.addSubview(stackView)
        
        var views = [UIView]()
        for _ in 1...10 {
            let checkRow = checkLine
            var checked = false
            checkRow.addAction(UIAction(title: "") { _ in
                if !checked {
                    checkRow.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
                    checked = true
                } else {
                    checkRow.setImage(UIImage(systemName: "square"), for: .normal)
                    checked = false
                }
            }, for: .touchUpInside)
            views.append(checkRow)
        }
        stackView.stack(views, axis: .vertical, width: nil, height: nil, spacing: 10)
        
        view.addSubview(postButton)
        
    }
    
    func addConstraints() {
        titleLabel.topToBottom(of: backButton)
        titleLabel.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10))

        scrollView.horizontalToSuperview()
        scrollView.topToBottom(of: titleLabel, offset: 20)
        
        
        stackView.edgesToSuperview(insets: UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30))
        stackView.width(to: view, offset: -60)
        
        scrollView.height(to: stackView, offset: -1)
        
        checkLine.height(50)
        
        postButton.height(50)
        postButton.bottomToSuperview(offset: -10, usingSafeArea: true)
        postButton.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
    }
    
}
