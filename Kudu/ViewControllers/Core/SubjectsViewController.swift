//
//  SubjectsViewController.swift
//  Kudu
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit
import TinyConstraints

class SubjectsViewController: UIViewController {

   
    private let titleBar = TitleBar(title: "Subjects", backButton: false)
    
    private let fb = FirebaseModel.shared
    
    private let vGrid = Grid()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        titleBar.vc = self
        if let image = fb.currentUser.profileImage {
            titleBar.profileImage.image = image
        }
        vGrid.vc = self
    }
    
    private func setupView() {
        
        view.backgroundColor = .systemBackground
        view.addSubview(self.titleBar)
        view.addSubview(vGrid)
    }
    
    private func setupConstraints() {
        titleBar.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        titleBar.height(70)
                
        vGrid.edgesToSuperview(excluding: .top, insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), usingSafeArea: true)
        vGrid.topToBottom(of: titleBar)
    }
    
}




