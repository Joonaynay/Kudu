//
//  SubjectsViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit
import TinyConstraints

class SubjectsViewController: UIViewController {

   
    private let titleBar = TitleBar(title: "Subjects", backButton: false)
    
    private let auth = AuthModel.shared
            
    private let vGrid = Grid()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        titleBar.vc = self
        if let image = auth.currentUser.profileImage {
            titleBar.menuButton.setImage(image, for: .normal)
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
                
        vGrid.edgesToSuperview(excluding: .top, insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        vGrid.topToBottom(of: titleBar, offset: 5)
    }
    
}




