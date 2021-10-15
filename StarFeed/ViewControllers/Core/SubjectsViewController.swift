//
//  SubjectsViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit
import TinyConstraints

class SubjectsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var titleBar: TitleBar!
            
    var vGrid: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        titleBar = TitleBar(title: "Subjects", vc: self)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: (view.width / 2) - 15, height: view.width / 4)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        vGrid = UICollectionView(frame: .zero, collectionViewLayout: layout)
        vGrid.dataSource = self
        vGrid.delegate = self
        vGrid.backgroundColor = .clear
        vGrid.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
        vGrid.showsVerticalScrollIndicator = false
        
        view.addSubview(vGrid)
        
        
    }
    
    private func setupConstraints() {
                
        vGrid.edgesToSuperview(excluding: .top, insets: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        vGrid.topToBottom(of: titleBar)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 50
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier, for: indexPath)
        return cell
    }
}



class CustomCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "cell"
    
    let button = Button(text: "sup man", color: .red)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(button)
        backgroundColor = .blue
        addConstraintsToCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addConstraintsToCell() {
        
        button.edgesToSuperview()
        
    }
    
}
