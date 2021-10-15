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
        titleBar = TitleBar(title: "Subjects", vc: self)
        vGrid = Grid(vc: self)
        view.addSubview(vGrid)
        
        
    }
    
    private func setupConstraints() {
                
        vGrid.edgesToSuperview(excluding: .top, insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        vGrid.topToBottom(of: titleBar)
    }
    
}




