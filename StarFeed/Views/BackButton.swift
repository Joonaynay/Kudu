//
//  BackButton.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/13/21.
//

import UIKit
import TinyConstraints

class BackButton: UIButton {
    
    let vc: UIViewController

    init(vc: UIViewController) {
        self.vc = vc
        super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        setImage(UIImage(systemName: "chevron.left"), for: .normal)
        vc.view.addSubview(self)
        height(50)
        width(50)
        leadingToSuperview(offset: 10)
        topToSuperview(offset: 10, usingSafeArea: true)
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
        
    }
    
    @objc private func didTap() {
        vc.navigationController?.popViewController(animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
