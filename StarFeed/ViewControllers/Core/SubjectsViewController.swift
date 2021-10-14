//
//  SubjectsViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit

class SubjectsViewController: UIViewController {
    
    private var titleBar: TitleBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        titleBar = TitleBar(title: "Subjects", vc: self)
    }
    
    private func setupConstraints() {

    }
}
