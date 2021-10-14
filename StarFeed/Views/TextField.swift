//
//  TextField.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/13/21.
//

import UIKit

class TextField: UITextField, UITextFieldDelegate {
    let insets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    
    init(text: String) {
        super.init(frame: .zero)
        placeholder = text
        backgroundColor = .secondarySystemBackground
        returnKeyType = .done
        delegate = self
    }
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        return false
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
