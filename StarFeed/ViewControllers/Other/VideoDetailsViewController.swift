//
//  VideoDetailsViewController.swift
//  StarFeed
//
//  Created by Wendy Buhler on 10/27/21.
//

import UIKit

class VideoDetailsViewController: UIViewController {
    
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
        scrollView.refreshControl = nil
        scrollView.addSubview(stackView)
        scrollView.addSubview(image)
        
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
        
        image.topToSuperview()
        image.horizontalToSuperview()
        image.height(view.width * (9/16))
        
        stackView.edgesToSuperview(excluding: .top, insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        stackView.topToBottom(of: image, offset: 20)
        stackView.width(to: view, offset: -30)
        
    }
    
}
