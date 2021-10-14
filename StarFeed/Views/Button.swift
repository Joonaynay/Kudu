//
//  Button.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/12/21.
//

import UIKit

class Button: UIButton {
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    init(text: String) {
        super.init(frame: .zero)
        label.text = text
        addSubview(label)
        clipsToBounds = true
        setTitleColor(.secondaryLabel, for: .highlighted)
        backgroundColor = UIColor.theme.blueColor
    }
    
    override func layoutSubviews() {
        label.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
    }
    
    override var isHighlighted: Bool {
        didSet {
            if state == .highlighted {
                label.textColor = .secondaryLabel
            } else {
                label.textColor = .label
            }
        
        }
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
