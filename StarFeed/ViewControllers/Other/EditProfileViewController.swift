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
    
    let label: UILabel = {
        
        let label = UILabel()
        label.text = "Settings"
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.backgroundColor = .systemBackground
        view.addSubview(label)
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
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! TableCell
        switch indexPath.row {
        case 0:
            cell.setupCell(title: "Delete Account", image: true)
        case 1:
            cell.setupCell(title: "Sign Out", image: true)
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
