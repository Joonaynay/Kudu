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
    
    private let fb = FirebaseModel.shared
    
    private let vGrid = Grid()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "24HrsAlert") {
            let alert = UIAlertController(title: "Please allow up to 24 hours for your post to be uploaded.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            UserDefaults.standard.set(false, forKey: "24HrsAlert")
        }
        
        titleBar.vc = self
        if let image = fb.currentUser.profileImage {
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
                
        vGrid.edgesToSuperview(excluding: .top, insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), usingSafeArea: true)
        vGrid.topToBottom(of: titleBar)
    }
    
}




