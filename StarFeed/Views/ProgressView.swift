//
//  ProgressView.swift
//  StarFeed
//
//  Created by Wendy Buhler on 10/18/21.
//

import UIKit

class ProgressView: UIView {

    public let activity = UIActivityIndicatorView()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
        addSubview(activity)
        activity.centerInSuperview()
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start() {
        backgroundColor = .black.withAlphaComponent(0.1)
        self.activity.startAnimating()
        isUserInteractionEnabled = true
    }
    
    func stop() {
        backgroundColor = .clear
        self.activity.stopAnimating()
        isUserInteractionEnabled = false
    }
    
}
