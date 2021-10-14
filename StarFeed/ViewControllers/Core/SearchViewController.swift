//
//  SearchViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit

class SearchViewController: UIViewController {
    
    private var titleBar: TitleBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        titleBar = TitleBar(title: "Search", vc: self)
        view.backgroundColor = .systemBackground
    }
    
    private func setupConstraints() {

    }
}
