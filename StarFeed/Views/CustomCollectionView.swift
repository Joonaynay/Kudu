//
//  CustomCollectionView.swift
//  StarFeed
//
//  Created by Forrest Buhler on 11/1/21.
//

import UIKit

class CustomCollectionView: UICollectionView {

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        super.init(frame: .zero, collectionViewLayout: layout)
        backgroundColor = .clear
        register(PostView.self, forCellWithReuseIdentifier: "post")
        showsVerticalScrollIndicator = false
        delaysContentTouches = false
        refreshControl = UIRefreshControl()
        alwaysBounceVertical = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIButton || view is UITextField {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
}
