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

class NewPostViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
        
    private var imageView = UIImageView()
    
    private let scrollView = ScrollView()
    private let stackView = TinyView()
    
    private var backButton: BackButton!
    private let titleText = TextField(text: "Title")
    private let imageButton = Button(text: "Select a thumbnail...", color: UIColor.theme.blueColor)
    private let videoButton = Button(text: "Select a video...", color: UIColor.theme.blueColor)
    private let videoView = UIButton()
    private let nextButton = Button(text: "Next", color: UIColor.theme.blueColor)
    
    private var movieURL: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        // View
        view.backgroundColor = .systemBackground
        
        // Back Button
        backButton = BackButton(vc: self)
        view.addSubview(backButton)
        
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
                self.present(VideoPlayer(url: url), animated: true)
            }
            
        }, for: .touchUpInside)
        
        // Next Button
        nextButton.addAction(UIAction(title: "") { _ in
            self.navigationController?.pushViewController(NewPostSubjectsViewController(), animated: true)
        }, for: .touchUpInside)

        
        //Scroll View
        view.addSubview(scrollView)
        
        // Stack View
        scrollView.addSubview(stackView)
        stackView.stack([titleText, imageButton, imageView, videoButton, videoView, nextButton], axis: .vertical, width: nil, height: nil, spacing: 10)
        

        
    }
    

    private func setupConstraints() {
        scrollView.horizontalToSuperview()
        scrollView.topToBottom(of: backButton)
        
        stackView.edgesToSuperview(insets: TinyEdgeInsets(top: 15, left: 15, bottom: 0, right: 15))
        stackView.width(view.width - 30)
        
        scrollView.height(to: stackView, offset: 14)
        
        imageView.heightToWidth(of: stackView, multiplier: 9/16)
        videoView.heightToWidth(of: stackView, multiplier: 9/16)

        
        titleText.height(50)
        imageButton.height(50)
        videoButton.height(50)
        nextButton.height(50)

    }
    
    
    func presentImagePicker(type: [String]) {
        let picker = ImagePicker(vc: self, mediaTypes: type, allowsEditing: type == ["public.image"])
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
            videoView.layer.addSublayer(videoPlayer)
            videoPlayer.frame = videoView.bounds
            videoPlayer.videoGravity = .resizeAspectFill
        }
    }
}
