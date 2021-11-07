//
//  BackButton.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/13/21.
//

import UIKit
import TinyConstraints

class BackButton: UIButton {
    
    weak var vc: UIViewController?

    init() {
        super.init(frame: .zero)
        setImage(UIImage(systemName: "chevron.left"), for: .normal)
        contentVerticalAlignment = .fill
        contentHorizontalAlignment = .fill
        imageEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        addTarget(self, action: #selector(didTap), for: .touchUpInside)        
    }
    
    func setupBackButton() {
        height(45)
        width(45)
        leadingToSuperview()
        topToSuperview(offset: 10, usingSafeArea: true)
    }
    
    @objc private func didTap() {
        vc?.navigationController?.popViewController(animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
