//
//  CollectionView.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/17/21.
//

import UIKit

class CollectionView: UICollectionView {
        
    init() {        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        super.init(frame: .zero, collectionViewLayout: layout)
        register(PostView.self, forCellWithReuseIdentifier: "post")
        refreshControl = UIRefreshControl()
        showsVerticalScrollIndicator = false
        backgroundColor = .clear
        delaysContentTouches = false
        alwaysBounceVertical = true        
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIButton || view is UITextField {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


