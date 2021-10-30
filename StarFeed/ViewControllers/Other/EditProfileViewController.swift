//
//  EditProfileViewController.swift
//  StarFeed
//
//  Created by Wendy Buhler on 10/17/21.
//

import UIKit
import FirebaseAuth

class EditProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let auth = AuthModel.shared
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    weak var vc: UIViewController?
    
    let label: UILabel = {
        
        let label = UILabel()
        label.text = "Settings"
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.textAlignment = .center
        return label
    }()
    
    private let xButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.tintColor = UIColor.theme.accentColor
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.backgroundColor = .systemBackground
        view.addSubview(label)
        xButton.addAction(UIAction() { _ in
            self.dismiss(animated: true)
        }, for: .touchUpInside)
        view.addSubview(xButton)
        setupView()
        addConstraints()
    }
    
    private func setupView() {
        tableView.register(TableCell.self, forCellReuseIdentifier: "tableCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .systemBackground
    }
    
    private func addConstraints() {
        
        tableView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        tableView.topToBottom(of: label, offset: -20)
        
        label.topToSuperview(offset: 10)
        label.centerXToSuperview()
        
        xButton.topToSuperview(offset: 15, usingSafeArea: true)
        xButton.trailingToSuperview(offset: 15)
        xButton.height(25)
        xButton.width(25)
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! TableCell
        switch indexPath.row {
        case 0:
            cell.setupCell(title: "Delete Account", image: true)
        case 1:
            cell.setupCell(title: "Sign Out", image: true)
        case 2:
            cell.setupCell(title: "Change Password", image: true)
        case 3:
            cell.setupCell(title: "Change Username", image: true)
        default:
            cell.setupCell(title: "Title", image: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            // Delete Account
            let alert = UIAlertController(title: "Delete Account", message: "Please type in your password to delete your account.", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
                self.auth.signIn(email: Auth.auth().currentUser!.email!, password: alert.textFields!.first!.text!) { error in
                    if error == nil {
                        self.auth.deleteUser { error in
                            if error == nil {
                                let login = UINavigationController(rootViewController: LoginViewController())
                                login.modalTransitionStyle = .flipHorizontal
                                login.modalPresentationStyle = .fullScreen
                                login.navigationBar.isHidden = true
                                self.present(login, animated: true)
                            }
                        }
                    } else {
                        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                        self.present(alert, animated: true)
                    }
                    
                }
            }))
            self.present(alert, animated: true)
            
        case 1:
            //Sign Out
            let alert = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Sign Out", style: .default, handler: { _ in
                self.auth.signOut { error in
                    let login = UINavigationController(rootViewController: LoginViewController())
                    login.modalTransitionStyle = .flipHorizontal
                    login.modalPresentationStyle = .fullScreen
                    login.navigationBar.isHidden = true
                    self.present(login, animated: true)
                }
            }))
            self.present(alert, animated: true)
        case 2:
            self.dismiss(animated: false)
            vc?.navigationController?.pushViewController(ChangePasswordViewController(), animated: true)
        case 3:
            let alert = UIAlertController(title: "Change Username", message: "Please type in your new username.", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "New Username"
            }
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
                self.auth.changeUsername(newUsername: alert.textFields!.first!.text!) { error in
                    if let error = error {
                        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                        self.present(alert, animated: true)
                    } else {
                        if let vc = self.vc as? ProfileViewController {
                            vc.username.text = alert.textFields?.first?.text
                        }
                        let alert = UIAlertController(title: "Success", message: "Username has successfully been changed.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                        self.present(alert, animated: true)
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        default:
            return
        }
    }
    
    
    
}

class TableCell: UITableViewCell {
    let imageUIView: UIImageView = {
        
        let image = UIImageView()
        image.image = UIImage(systemName: "chevron.right")
        return image
    }()
    
    let title: UILabel = {
        
        let title = UILabel()
        return title
        
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    func setupCell(title: String, image: Bool) {
        
        self.title.text = title
        if image {
            self.addSubview(imageUIView)
        }
        addSubview(self.title)
        
        self.title.leadingToSuperview(offset: 20)
        self.title.centerYToSuperview()
        
        if image {
            self.imageUIView.trailingToSuperview(offset: 20)
            self.imageUIView.centerYToSuperview()
        }
        
    }
        
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ChangePasswordViewController: UIViewController {
    
    private let auth = AuthModel.shared
    
    private let backButton = BackButton()
    
    public let oldPassword = CustomTextField(text: "Old Password", image: nil)
    
    public let newPassword = CustomTextField(text: "New Password", image: nil)
    
    public let confirmPassword = CustomTextField(text: "Confirm Password", image: nil)
    
    private let stackView = UIView()
    
    public let doneButton = CustomButton(text: "Done", color: UIColor.theme.blueColor)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addConstraints()
        
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)
        
        backButton.vc = self
        
        oldPassword.vc = self
        oldPassword.isSecureTextEntry = true
        newPassword.vc = self
        newPassword.isSecureTextEntry = true
        confirmPassword.vc = self
        confirmPassword.isSecureTextEntry = true
        
        stackView.stack([
            oldPassword, newPassword, confirmPassword
        ], spacing: 10)
        view.addSubview(backButton)
        
        doneButton.isEnabled = false
        
        doneButton.addAction(UIAction() { _ in
            if self.newPassword.text! == self.confirmPassword.text! {
                self.auth.changePassword(oldPassword: self.oldPassword.text!, newPassword: self.newPassword.text!) { error in
                    if error != nil {
                        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                        self.present(alert, animated: true)
                    } else {
                        let alert = UIAlertController(title: "Success", message: "Password was successfully changed.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                        self.present(alert, animated: true)
                    }
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "Password and confirm password do not match", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)
            }
        }, for: .touchUpInside)
        
        view.addSubview(doneButton)
    }
    
    private func addConstraints() {
        backButton.setupBackButton()
        
        stackView.topToBottom(of: backButton, offset: 20)
        stackView.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        
        oldPassword.height(50)
        newPassword.height(50)
        confirmPassword.height(50)
        
        doneButton.bottomToSuperview(offset: -15)
        doneButton.height(50)
        doneButton.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
    }
}
