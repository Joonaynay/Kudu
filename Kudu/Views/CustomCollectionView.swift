//
//  CustomCollectionView.swift
//  Kudu
//
//  Created by Forrest Buhler on 11/1/21.
//

import UIKit
import TinyConstraints

class CustomCollectionView: UICollectionView {
        
    public var bottomRefresh = BottomRefresh()

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

class BottomRefresh: UIView {
    
    private let progressView = UIActivityIndicatorView()
    public var isLoading = false
    
    init() {
        super.init(frame: .zero)
        addSubview(progressView)
        progressView.edgesToSuperview()
        progressView.centerInSuperview()        
    }
    
    required init?(coder: NSCoder) {
    
        fatalError("init(coder:) has not been implemented")
    }
            
    override func didMoveToSuperview() {
        guard superview != nil else {
            return 
        }
        self.height(0)
        self.bottomToSuperview(usingSafeArea: true)
        self.centerXToSuperview()
        self.horizontalToSuperview()
    }
    
    func start() {
        for constraint in self.constraints {
            if constraint.firstAttribute == .height {
                constraint.constant += 50
            }
        }
        superview?.layoutIfNeeded()
        self.isLoading = true
        self.progressView.startAnimating()
    }
    
    func stop() {
        for constraint in self.constraints {
            if constraint.firstAttribute == .height {
                constraint.constant -= 50
            }
        }
        superview?.layoutIfNeeded()
        self.isLoading = false
        self.progressView.stopAnimating()
        if let collectionView = superview?.subviews.first(where: { view in view is CustomCollectionView }) as? CustomCollectionView {
            if collectionView.contentOffset.y != 0 {
                collectionView.contentOffset.y += 50
            }
        }
    }
}
