//
//  NewPostSubjectsViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/14/21.
//

import UIKit
import TinyConstraints

class NewPostSubjectsViewController: UIViewController {
    
    let fb = FirebaseModel.shared
    
    private let scrollView = CustomScrollView()
    private let backButton = BackButton()
    private let stackView = TinyView()
    
    public let titleString: String
    public var subjects: [String] = []
    public let image: UIImage?
    public let movieURL: URL?
    
    
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
        return button
    }
    
    private let postButton = CustomButton(text: "Post", color: UIColor.theme.blueColor)
        
    var desc: String
    
    init(movieURL: URL?, image: UIImage?, titleString: String, desc: String) {
        self.movieURL = movieURL
        self.image = image
        self.titleString = titleString
        self.desc = desc
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        backButton.vc = self
    }
    
    func setupView() {
        view.addSubview(scrollView)
        view.backgroundColor = .systemBackground
        
        
        view.addSubview(backButton)
        backButton.setupBackButton()
        
        view.addSubview(titleLabel)
        
        scrollView.addSubview(stackView)
        scrollView.refreshControl = nil
        
        var views = [UIView]()
        for subject in fb.subjects {
            let checkRow = checkLine
            checkRow.setTitle(subject.name, for: .normal)
            var checked = false
            checkRow.addAction(UIAction(title: "") { _ in
                if !checked {
                    checkRow.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
                    self.subjects.append(subject.name)
                    checked = true
                } else {
                    checkRow.setImage(UIImage(systemName: "square"), for: .normal)
                    let index = self.subjects.firstIndex(where: { string in
                        subject.name == string
                    })
                    self.subjects.remove(at: index!)
                    checked = false
                }
                if self.subjects.count > 3 || self.subjects.count < 1 {
                    self.postButton.isEnabled = false
                } else if self.subjects.count > 0 {
                    self.postButton.isEnabled = true
                }
            }, for: .touchUpInside)
            views.append(checkRow)
        }
        stackView.stack(views, axis: .vertical, width: nil, height: nil, spacing: 10)
        
        //Post button
        postButton.isEnabled = false
        postButton.addAction(UIAction(title: "") { _ in
            if let image = self.image, let movieURL = self.movieURL {
                UserDefaults.standard.set(true, forKey: "24HrsAlert")
                self.fb.addPost(image: image, title: self.titleString, subjects: self.subjects, movie: movieURL, description: self.desc)
                self.navigationController?.popToRootViewController(animated: true)
            }
            
        }, for: .touchUpInside)
        
        view.addSubview(postButton)
        
    }
    
    func addConstraints() {
        titleLabel.topToBottom(of: backButton)
        titleLabel.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))

        scrollView.horizontalToSuperview()
        scrollView.topToBottom(of: titleLabel, offset: 20)
        scrollView.bottomToTop(of: postButton, offset: -10)
        
        
        stackView.edgesToSuperview(insets: UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30))
        stackView.width(to: view, offset: -60)
                
        checkLine.height(50)
        
        postButton.height(50)
        postButton.bottomToSuperview(offset: -10, usingSafeArea: true)
        postButton.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
    }
    
}
