//
//  ProfilePictureViewController.swift
//  StarFeed
//
//  Created by Wendy Buhler on 10/16/21.
//

import UIKit

class ProfilePictureViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    private let storage = StorageModel.shared
    private let fb = FirebaseModel.shared
    private let file = FileManagerModel.shared
    
    let showBackButton: Bool
    
    init(showBackButton: Bool) {
        self.showBackButton = showBackButton
        super.init(nibName: nil, bundle: nil)
    }
    
    let backButton = BackButton()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var image: UIImage?
    
    let profileLabel: UILabel = {
        
        let label = UILabel()
        label.text = "Choose a profile picture"
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.textAlignment = .center
        return label
        
    }()
    
    let profileImageButton: UIButton = {
        
        let button = UIButton()
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        return button
        
    }()
    
    let skipButton = Button(text: "Skip", color: .clear)
    
    let doneButton = Button(text: "Done", color: UIColor.theme.blueColor)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addConstraints()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        backButton.vc = self
    }
    
    func setupView() {
        
        view.backgroundColor = .systemBackground
        view.addSubview(profileLabel)
        view.addSubview(profileImageButton)
        view.addSubview(doneButton)
        if !showBackButton {
            view.addSubview(skipButton)
        } else {
            view.addSubview(backButton)
        }
        
        
        
        if let image = fb.currentUser.profileImage {
            profileImageButton.setImage(image, for: .normal)
            profileImageButton.imageView!.layer.masksToBounds = false
            profileImageButton.imageView!.clipsToBounds = true
        } else {
            profileImageButton.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
            profileImageButton.imageView!.layer.masksToBounds = false
            profileImageButton.imageView!.clipsToBounds = true
        }
        
        
        profileImageButton.addAction(UIAction() { _ in
            self.presentImagePicker(type: ["public.image"])
        }, for: .touchUpInside)
        
        doneButton.isEnabled = false
        doneButton.addAction(UIAction() { _ in
            if let image = self.image {
                self.fb.currentUser.profileImage = image
                self.storage.saveImage(path: "Profile Images", file: self.fb.currentUser.id, image: image)
                self.file.saveImage(image: image, name: self.fb.currentUser.id)
                self.fb.currentUser.profileImage = image
                
                if self.showBackButton {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    let home = TabBarController()
                    home.modalTransitionStyle = .flipHorizontal
                    home.modalPresentationStyle = .fullScreen
                    self.present(home, animated: true)
                }
            }
            
        }, for: .touchUpInside)
        
        skipButton.addAction(UIAction() { _ in
            let home = TabBarController()
            home.modalTransitionStyle = .flipHorizontal
            home.modalPresentationStyle = .fullScreen
            self.present(home, animated: true)
            
        }, for: .touchUpInside)
    }
    
    func addConstraints() {
        
        if showBackButton {
            backButton.setupBackButton()
        }
        
        if showBackButton {
            profileLabel.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
            profileLabel.topToBottom(of: backButton)
        } else {
            profileLabel.edgesToSuperview(excluding: .bottom, insets: UIEdgeInsets(top: 20, left: 15, bottom: 0, right: 15), usingSafeArea: true)
        }
        profileLabel.centerXToSuperview()
        
        profileImageButton.centerYToSuperview(offset: -20)
        profileImageButton.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50))
        profileImageButton.heightToWidth(of: view, offset: -100)
        profileImageButton.imageView!.layer.cornerRadius = profileImageButton.bounds.width / 2
        
        if !showBackButton {
            doneButton.bottomToTop(of: skipButton)
        } else {
            doneButton.bottomToSuperview(offset: -15)
        }
        doneButton.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        doneButton.height(50)
        
        if !showBackButton {
            skipButton.bottomToSuperview(offset: -15)
            skipButton.horizontalToSuperview(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
            skipButton.height(50)
        }
    }
    
    func presentImagePicker(type: [String]) {
        
        let picker = ImagePicker(mediaTypes: type, allowsEditing: type == ["public.image"])
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        if let image = info[.editedImage] as? UIImage {
            self.image = image
            profileImageButton.setImage(image, for: .normal)
            profileImageButton.imageView!.layer.masksToBounds = false
            profileImageButton.imageView!.layer.cornerRadius = profileImageButton.bounds.width / 2
            profileImageButton.imageView!.clipsToBounds = true
            doneButton.isEnabled = true
        }
    }
}
