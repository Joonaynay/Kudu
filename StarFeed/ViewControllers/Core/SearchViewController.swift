//
//  SearchViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit

class SearchViewController: UIViewController {
    
    private var titleBar: TitleBar!
    
    private var textField = TextField(text: "Search...", image: "magnifyingglass")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        let titleBar = TitleBar(title: "Search", backButton: false)
        titleBar.vc = self
        self.titleBar = titleBar
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
