//
//  VideoDetailsViewController.swift
//  StarFeed
//
//  Created by Wendy Buhler on 10/27/21.
//

import UIKit

class VideoDetailsViewController: UIViewController, UITextViewDelegate {
    
    private let image = UIImageView()
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        label.sizeToFit()
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        return label
    }()
    
    private let desc: UILabel = {
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
    
    private let post: Post
    
    private let editTitleButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.tintColor = UIColor.theme.accentColor
        return button
    }()
    
    private var titleTextField: UITextView = {
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
    
    private let fb = FirebaseModel.shared
    
    init(post: Post) {
        self.post = post
        self.image.image = post.image
        self.image.contentMode = .scaleAspectFill
        self.image.clipsToBounds = true
        self.desc.text = post.description
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
        view.addSubview(scrollView)
        view.addSubview(xButton)
        view.addSubview(rectLine)
        view.addSubview(editTitleButton)
        view.addSubview(titleTextField)
        view.addSubview(titleDoneButton)
        scrollView.refreshControl = nil
        scrollView.addSubview(stackView)
        scrollView.addSubview(image)
        
        titleTextField.font = titleLabel.font
        titleTextField.textContainerInset = UIEdgeInsets(top: 14, left: 9, bottom: 14, right: 9)
        titleTextField.delegate = self
        
        editTitleButton.addAction(UIAction() { _ in
            self.titleTextField.horizontalToSuperview()
            self.titleTextField.topToBottom(of: self.image, offset: 32)
            self.titleTextField.height(min: 50, max: 1000)
            self.titleTextField.font = self.titleLabel.font
            self.titleTextField.text = self.post.title
            
            self.titleDoneButton.topToBottom(of: self.titleTextField, offset: 5)
            self.titleDoneButton.trailing(to: self.titleTextField, offset: -5)
            self.titleDoneButton.height(50)
            self.titleDoneButton.width(self.view.width / 4)
        }, for: .touchUpInside)
        
        titleDoneButton.addAction(UIAction() { _ in
            //self.fb.db.save(collection: "posts", document: self.post.id, field: "title", data: self.titleTextField.text!)
            for constraint in self.titleTextField.constraints {
                constraint.isActive = false
            }
            for constraint in self.titleDoneButton.constraints {
                constraint.isActive = false
            }
        }, for: .touchUpInside)
        
        let descHeader = header
        descHeader.text = "DESCRIPTION"
        
        self.xButton.addAction(UIAction() { _ in
            self.dismiss(animated: true)
        }, for: .touchUpInside)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descHeader)
        if desc.text == "" {
            desc.text = "No description was provided."
        }
        stackView.addArrangedSubview(desc)
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
        
        editTitleButton.bottom(to: titleLabel)
        editTitleButton.leadingToTrailing(of: titleLabel, offset: -7)
        
        image.topToSuperview()
        image.horizontalToSuperview()
        image.height(view.width * (9/16))
        
        stackView.edgesToSuperview(excluding: .top, insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 30))
        stackView.topToBottom(of: image, offset: 30)
        stackView.width(to: view, offset: -30)
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if titleTextField.text.count >= 100 {
            titleDoneButton.isEnabled = false
            let alert = UIAlertController(title: "Title must be 100 characters or less.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
            present(alert, animated: true)
        } else {
            titleDoneButton.isEnabled = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if titleTextField.text.isEmpty {
            titleTextField.text = "Title"
            titleTextField.textColor = .systemGray2
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if titleTextField.text == "Title" {
            titleTextField.text = ""
        }
        titleTextField.textColor = .label
    }
    
}
