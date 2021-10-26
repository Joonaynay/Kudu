//
//  SubjectPostViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/15/21.
//

import UIKit

class SubjectPostViewController: UIViewController {

    private let fb = FirebaseModel.shared

    private var titleBar: TitleBar!

    private let scrollView = CustomScrollView()
    private var stackView = UIStackView()
    private let subject: Subject
            
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        reload()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        titleBar.vc = self
        if let image = fb.currentUser.profileImage {
            titleBar.menuButton.setImage(image, for: .normal)
        }
        reload()
    }
    
    init(subject: Subject) {
        self.subject = subject
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        //View
        view.backgroundColor = .systemBackground
        
        //Title bar
        self.titleBar = TitleBar(title: subject.name, backButton: true)
        view.addSubview(titleBar)
        
        //Scroll View
        scrollView.refreshControl?.addAction(UIAction() { _ in
            self.fb.loadPosts {
                self.scrollView.refreshControl?.endRefreshing()
                self.reload()
            }
        }, for: .valueChanged)
        view.addSubview(scrollView)
        
        //StackView
        stackView.axis = .vertical
        scrollView.addSubview(stackView)

    }
    
    private func reload() {
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        for post in fb.posts {
            post.vc = self
            stackView.addArrangedSubview(post)
        }
    }
        
 
    private func setupConstraints() {
        titleBar.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        titleBar.height(70)
        
        scrollView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        scrollView.topToBottom(of: titleBar)
        

        stackView.edgesToSuperview()
        stackView.width(view.width)
        


    }
    
}
