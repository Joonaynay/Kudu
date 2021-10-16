//
//  SubjectPostViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/15/21.
//

import UIKit

class SubjectPostViewController: UIViewController {    
    private var titleBar: TitleBar!
    
    private var stackView = UIView()
    
    let subject: Subject
    
    init(subject: Subject) {
        self.subject = subject
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        // View
        view.backgroundColor = .systemBackground
        
        // Title Bar
        let titleBar = TitleBar(title: subject.name, backButton: true)
        titleBar.vc = self
        self.titleBar = titleBar
        view.addSubview(self.titleBar)
        
        let postView = PostView(post: Post(title: "Title", image: UIImage(systemName: "person.circle.fill")!))
        stackView.stack([postView])
        view.addSubview(stackView)
        
        
    }
    
    private func setupConstraints() {
        titleBar.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        titleBar.height(70)
        
        stackView.edgesToSuperview(excluding: .top)
        stackView.topToBottom(of: titleBar)
        stackView.widthToSuperview()
        
    }
    
}
