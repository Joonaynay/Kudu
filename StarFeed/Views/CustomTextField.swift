//
//  TextField.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/13/21.
//

import UIKit
import TinyConstraints

class CustomTextField: UITextField, UITextFieldDelegate {
    var insets: UIEdgeInsets!
    
    var image: UIImageView!
    
    weak var vc: UIViewController?
    
    init(text: String, image: String?) {
        super.init(frame: .zero)
        addAction(UIAction() { _ in
            self.textChanged()
        }, for: .allEditingEvents)
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
    
    func textChanged() {
        if let vc = vc as? NewPostViewController {
            if vc.imageView.image != nil && vc.movieURL != nil && self.text != "" {
                vc.nextButton.isEnabled = true
            } else {
                vc.nextButton.isEnabled = false
            }
        } else if let vc = vc as? CreateAccountViewController {
            if !vc.firstName.text!.isEmpty && !vc.lastName.text!.isEmpty && !vc.email.text!.isEmpty && !vc.username.text!.isEmpty && !vc.password.text!.isEmpty && !vc.confirmPassword.text!.isEmpty {
                vc.createAccountButton.isEnabled = true
            } else {
                vc.createAccountButton.isEnabled = false
            }
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
