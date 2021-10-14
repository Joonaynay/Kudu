//
//  ScrollView.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/13/21.
//

import UIKit

class ScrollView: UIScrollView {
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        delaysContentTouches = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false        
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
