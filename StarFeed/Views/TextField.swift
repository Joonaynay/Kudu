//
//  TextField.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/13/21.
//

import UIKit
import TinyConstraints

class TextField: UITextField, UITextFieldDelegate {
    var insets: UIEdgeInsets!
    
    var image: UIImageView!
    
    init(text: String, image: String?) {
        super.init(frame: .zero)
        placeholder = text
        backgroundColor = .secondarySystemBackground
        returnKeyType = .done
        delegate = self
        if let image = image {
            self.image = UIImageView(image: UIImage(systemName: image))
            insets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 12)
            addSubview(self.image)
            self.image.leadingToSuperview(offset: 9)
            self.image.tintColor = .systemGray2
            self.image.height(23)
            self.image.width(23)
            self.image.centerYToSuperview()
        } else {
            insets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        }
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
