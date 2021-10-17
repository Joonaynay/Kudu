//
//  SearchViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit

class SearchViewController: UIViewController {
    
    private let titleBar = TitleBar(title: "Search", backButton: false)
    
    private var textField = TextField(text: "Search...", image: "magnifyingglass")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        titleBar.vc = self
    }
    
    private func setupView() {
        view.addSubview(self.titleBar)        
        view.addSubview(textField)
        view.backgroundColor = .systemBackground
    }
    
    private func setupConstraints() {
        
        titleBar.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        titleBar.height(70)
        
        textField.topToBottom(of: titleBar, offset: 5)
        textField.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        textField.height(50)
        
    }
}
