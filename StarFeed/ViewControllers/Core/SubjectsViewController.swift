//
//  SubjectsViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit
import TinyConstraints

class SubjectsViewController: UIViewController {
    
    var titleBar: TitleBar!
            
    var vGrid: Grid!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        let titleBar = TitleBar(title: "Subjects", backButton: false)
        titleBar.vc = self
        self.titleBar = titleBar
        view.addSubview(self.titleBar)
        
        let vGrid = Grid()
        vGrid.vc = self
        self.vGrid = vGrid
        view.addSubview(vGrid)
    }
    
    private func setupConstraints() {
        titleBar.edgesToSuperview(excluding: .bottom, usingSafeArea: true)
        titleBar.height(70)
                
        vGrid.edgesToSuperview(excluding: .top, insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        vGrid.topToBottom(of: titleBar, offset: 5)
    }
    
}




