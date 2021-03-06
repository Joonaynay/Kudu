//
//  NewPostViewController.swift
//  Kudu
//
//  Created by Forrest Buhler on 10/12/21.
//

import UIKit
import PhotosUI
import AVKit
import TinyConstraints

class NewPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    var imageView = UIImageView()
    
    private let scrollView = CustomScrollView()
    private let stackView = TinyView()
    
    private var backButton = BackButton()
    private let titleText = CustomTextField(text: "Title", image: nil)
    private let imageButton = CustomButton(text: "Select a thumbnail...", color: UIColor.theme.blueColor)
    private let videoButton = CustomButton(text: "Select a video...", color: UIColor.theme.blueColor)
    private let videoView = UIButton()
    let nextButton = CustomButton(text: "Next", color: UIColor.theme.blueColor)
    
    private let desc: UITextView = {
        let textView = UITextView()
        textView.isEditable = true
        textView.backgroundColor = .secondarySystemBackground
        textView.sizeToFit()
        textView.isScrollEnabled = false
        textView.textColor = .systemGray2
        textView.text = "Description"
        return textView
    }()
    
    private var header: UILabel {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 10, weight: .heavy)
        return label
    }
    
    var movieURL: URL?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !UserDefaults.standard.bool(forKey: "isFirstTime") {
            let alert = UIAlertController(title: "Important!!!", message: "", preferredStyle: .alert)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            let messageText = NSAttributedString(
                string: "Kudu is a place for inspiration, developing personal skills, and self improvement. Because of this we ask that you do not post any material that is unrelated to these topics. \n\nExamples of unrelated content include: \n\n- Memes \n\n- Posts about your weekend fun \n\n- Family photos, etc. \n\nIf you do post unrelated content then your account can and will be banned.",
                attributes: [
                    NSAttributedString.Key.paragraphStyle: paragraphStyle,
                    NSAttributedString.Key.foregroundColor : UIColor.label,
                    NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)
                ]
            )
            
            alert.setValue(messageText, forKey: "attributedMessage")
            
            let action = UIAlertAction(title: "I understand", style: .default) { _ in
                UserDefaults.standard.set(true, forKey: "isFirstTime")
            }
            alert.addAction(action)
            present(alert, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        backButton.vc = self
        titleText.vc = self
    }
    
    private func setupView() {
        // View
        view.backgroundColor = .systemBackground
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        // Back Button
        view.addSubview(backButton)
        backButton.setupBackButton()
        
        // Description
        desc.font = titleText.font
        desc.textContainerInset = UIEdgeInsets(top: 14, left: 9, bottom: 14, right: 9)
        desc.delegate = self
        
        // Image Button
        imageButton.addAction(UIAction(title: "") { [weak self] _ in
            self?.presentImagePicker(type: ["public.image"])
        }, for: .touchUpInside)
        
        //Image View
        imageView.backgroundColor = .secondarySystemBackground
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        
        // Video Button
        videoButton.addAction(UIAction(title: "") { [weak self] _ in
            self?.presentImagePicker(type: ["public.movie"])
        }, for: .touchUpInside)
        
        // Video View
        videoView.backgroundColor = .secondarySystemBackground
        
        videoView.addAction(UIAction(title: "") { [weak self] _ in
            if let url = self?.movieURL {
                let player = VideoPlayer(url: url)
                self?.present(player, animated: true)
            }
        }, for: .touchUpInside)
        
        // Next Button
        nextButton.addAction(UIAction(title: "") { [weak self] _ in
            guard let self = self else { return }
            if self.desc.text.count <= 1000 && self.titleText.text!.count <= 100 && self.imageView.image != nil && self.videoView.layer.sublayers?.first != nil {
                if self.desc.text == "Description" {
                    self.desc.text = ""
                    self.navigationController?.pushViewController(NewPostSubjectsViewController(movieURL: self.movieURL, image: self.imageView.image, titleString: self.titleText.text!, desc: self.desc.text!), animated: true)
                } else {
                    self.navigationController?.pushViewController(NewPostSubjectsViewController(movieURL: self.movieURL, image: self.imageView.image, titleString: self.titleText.text!, desc: self.desc.text!), animated: true)
                }
            } else {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .left
                let messageText = NSAttributedString(string: "Please make sure you have the following:\n\n- A title (100 characters) or less\n\n- A description (1,000 words or less)\n\n- A thumbnail selected\n\n- A video selected", attributes: [
                    NSAttributedString.Key.paragraphStyle: paragraphStyle,
                    NSAttributedString.Key.foregroundColor : UIColor.label,
                    NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)
                ])
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                alert.setValue(messageText, forKey: "attributedMessage")
                self.present(alert, animated: true)
            }
        }, for: .touchUpInside)
        nextButton.isEnabled = false
        
        
        //Scroll View
        view.addSubview(scrollView)
        scrollView.refreshControl = nil
        
        // Stack View
        scrollView.addSubview(stackView)
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        let titleHeader = header
        titleHeader.text = "TITLE"
                        
        let optionalHeader = header
        optionalHeader.text = "OPTIONAL"
        
        stackView.stack([titleHeader, titleText, imageButton, imageView, optionalHeader, desc, videoButton, videoView, nextButton], axis: .vertical, width: nil, height: nil, spacing: 10)
        
    }
    
    
    private func setupConstraints() {
        scrollView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        scrollView.topToBottom(of: backButton)
        
        stackView.edgesToSuperview(insets: TinyEdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
        stackView.width(view.width - 30)
        
        imageView.heightToWidth(of: stackView, multiplier: 9/16)
        videoView.heightToWidth(of: stackView, multiplier: 9/16)
        
        
        titleText.height(50)
        desc.height(min: 50, max: 1000, priority: .required, isActive: true)
        imageButton.height(50)
        videoButton.height(50)
        nextButton.height(50)
        
    }        
    
    
    func presentImagePicker(type: [String]) {
        
        let picker = ImagePicker(mediaTypes: type, allowsEditing: type == ["public.image"])
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        
        if let image = info[.editedImage] as? UIImage {
            self.imageView.image = image
        } else if let url = info[.mediaURL] as? URL {
            self.movieURL = url
            let videoPlayer = AVPlayerLayer(player: AVPlayer(url: url))
            videoPlayer.frame = videoView.bounds
            
            let play = UIImageView(image: UIImage(systemName: "play.circle.fill"))
            play.tintColor = .white
            play.frame = CGRect(x: videoView.bounds.width / 2 - 25, y: videoView.bounds.height / 2 - 25, width: 50, height: 50)
            
            view.addSubview(play)
            videoPlayer.addSublayer(play.layer)
            videoView.layer.addSublayer(videoPlayer)
            
        }
        if self.imageView.image != nil && titleText.text != "" {
            nextButton.isEnabled = true
        } else {
            nextButton.isEnabled = false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if desc.text.count >= 1000 {
            nextButton.isEnabled = false
            let alert = UIAlertController(title: "Description must be 1000 characters or less.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
            present(alert, animated: true)
        } else {
            nextButton.isEnabled = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if desc.text.isEmpty {
            desc.text = "Description"
            desc.textColor = .systemGray2
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if desc.text == "Description" {
            desc.text = ""
        }
        desc.textColor = .label
    }
    
    @objc func dismissKeyboard() {
        self.desc.endEditing(true)
    }
    
    
}
