//
//  NewPostViewController.swift
//  StarFeed
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
        label.font = UIFont.systemFont(ofSize: 8, weight: .heavy)
        return label
    }
    
    var movieURL: URL!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !UserDefaults.standard.bool(forKey: "isFirstTime") {
            let alert = UIAlertController(title: "Important!", message: "", preferredStyle: .alert)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            let messageText = NSAttributedString(
                string: "_Name_ is a place for inspiration, developing personal skills, and self improvement. Because of this we ask that you do not post any material that is unrelated to these topics. \n\nExamples of unrelated content include: \n\n- Memes \n\n- Posts about your weekend fun \n\n- Family photos, etc. \n\nIf you do post unrelated content then your account can and will be banned.",
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
        
        // Back Button
        view.addSubview(backButton)
        backButton.setupBackButton()
        
        // Description
        desc.font = titleText.font
        desc.textContainerInset = UIEdgeInsets(top: 14, left: 9, bottom: 14, right: 9)
        desc.delegate = self
        
        // Image Button
        imageButton.addAction(UIAction(title: "") { _ in
            self.presentImagePicker(type: ["public.image"])
        }, for: .touchUpInside)
        
        //Image View
        imageView.backgroundColor = .secondarySystemBackground
        
        // Video Button
        videoButton.addAction(UIAction(title: "") { _ in
            self.presentImagePicker(type: ["public.movie"])
        }, for: .touchUpInside)
        
        // Video View
        videoView.backgroundColor = .secondarySystemBackground

        videoView.addAction(UIAction(title: "") { _ in
            if let url = self.movieURL {
                let player = VideoPlayer(url: url)
                self.present(player, animated: true)
            }
        }, for: .touchUpInside)
        
        // Next Button
        nextButton.addAction(UIAction(title: "") { _ in
            self.navigationController?.pushViewController(NewPostSubjectsViewController(movieURL: self.movieURL, image: self.imageView.image, titleString: self.titleText.text!, desc: self.desc.text!), animated: true)
        }, for: .touchUpInside)
        nextButton.isEnabled = false

        
        //Scroll View
        view.addSubview(scrollView)
        scrollView.refreshControl = nil
        
        // Stack View
        scrollView.addSubview(stackView)
        let titleHeader = header
        titleHeader.text = "Title"
        
        let descHeader = header
        descHeader.text = "Description"
        stackView.stack([titleHeader, titleText, descHeader, desc, imageButton, imageView, videoButton, videoView, nextButton], axis: .vertical, width: nil, height: nil, spacing: 10)
        

        
    }
    

    private func setupConstraints() {
        scrollView.edgesToSuperview(excluding: .top)
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
        if imageView.image != nil && videoView.layer.sublayers?.first != nil && titleText.text != "" {
            nextButton.isEnabled = true
        } else {
            nextButton.isEnabled = false
        }
        
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
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if desc.text.isEmpty {
            desc.text = "Description"
            desc.textColor = .systemGray2
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        desc.text = ""
        desc.textColor = .label
    }
    
    
}
