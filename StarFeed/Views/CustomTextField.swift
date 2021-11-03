//
//  TextField.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/13/21.
//

import UIKit
import TinyConstraints

class CustomTextField: UITextField, UITextFieldDelegate {
    
    var image: UIImageView?
    
    weak var vc: UIViewController?
    
    init(text: String, image: String?) {
        super.init(frame: .zero)
        clearButtonMode = .whileEditing
        attributedPlaceholder = NSAttributedString(string: text, attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.systemGray2
        ])
        backgroundColor = .secondarySystemBackground
        returnKeyType = .done
        delegate = self
        if let image = image {
            self.image = UIImageView(image: UIImage(systemName: image))
            addSubview(self.image!)
            self.image!.leadingToSuperview(offset: 9)
            self.image!.tintColor = .systemGray2
            self.image!.height(23)
            self.image!.width(23)
            self.image!.centerYToSuperview()
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let vc = vc as? NewPostViewController {
            if vc.imageView.image != nil && vc.movieURL != nil && self.text != "" && self.text!.count <= 100 {
                vc.nextButton.isEnabled = true
            } else {
                vc.nextButton.isEnabled = false
            }
            if self.text!.count > 100 {
                vc.nextButton.isEnabled = false
                let alert = UIAlertController(title: "Title must be 100 characters long or less.", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                vc.present(alert, animated: true)
            } else {
                vc.nextButton.isEnabled = true
            }
        } else if let vc = vc as? CreateAccountViewController {
            if !vc.firstName.text!.isEmpty && !vc.lastName.text!.isEmpty && !vc.email.text!.isEmpty && !vc.username.text!.isEmpty && !vc.password.text!.isEmpty && !vc.confirmPassword.text!.isEmpty {
                vc.createAccountButton.isEnabled = true
            } else {
                vc.createAccountButton.isEnabled = false
            }
        } else if let vc = vc as? ChangePasswordViewController {
            if !vc.oldPassword.text!.isEmpty && !vc.newPassword.text!.isEmpty && !vc.confirmPassword.text!.isEmpty {
                vc.doneButton.isEnabled = true
            } else {
                vc.doneButton.isEnabled = false
            }
        } else if let vc = vc as? ChangeEmailViewController {
            if !vc.password.text!.isEmpty && !vc.newEmail.text!.isEmpty && !vc.confirmEmail.text!.isEmpty {
                vc.doneButton.isEnabled = true
            } else {
                vc.doneButton.isEnabled = false
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        return false
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var insets = UIEdgeInsets()
        if self.image?.image != nil {
            insets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 45)
        } else {
            insets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 45)
        }
        return bounds.inset(by: insets)
    }
    
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.offsetBy(dx: self.bounds.width / 2.4, dy: 0)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var insets = UIEdgeInsets()
        if self.image?.image != nil {
            insets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 45)
        } else {
            insets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 45)
        }
        return bounds.inset(by: insets)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
