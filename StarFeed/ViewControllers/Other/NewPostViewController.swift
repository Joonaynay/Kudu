//
//  NewPostViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/12/21.
//

import UIKit
import TinyConstraints

class NewPostViewController: UIViewController {
    
    private let scrollView = ScrollView()
    private let stackView = TinyView()
    private var backButton: BackButton!
    private let titleText = TextField(text: "Title")
    private let imageButton = Button(text: "Select a thumbnail...")
    private let videoButton = Button(text: "Select a video...")
    private let nextButton = Button(text: "Next")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        // View
        view.backgroundColor = .systemBackground
        
        // Back Button
        backButton = BackButton(vc: self)
        view.addSubview(backButton)
        
        // Image Button
        imageButton.addTarget(self, action: #selector(didTapImageButton), for: .touchUpInside)
        
        //Scroll View
        view.addSubview(scrollView)
        
        // Stack View
        scrollView.addSubview(stackView)
        stackView.stack([titleText, imageButton, videoButton, nextButton], axis: .vertical, width: nil, height: nil, spacing: 10)
        
        
    }
    

    private func setupConstraints() {
        scrollView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        scrollView.topToBottom(of: backButton)
        
        stackView.edgesToSuperview(insets: TinyEdgeInsets(top: 15, left: 15, bottom: 0, right: 15))
        stackView.width(view.width - 30)
        
        titleText.height(50)
        imageButton.height(50)
        videoButton.height(50)
        nextButton.height(50)

    }
    
    @objc func didTapImageButton() {
        
    }

}
