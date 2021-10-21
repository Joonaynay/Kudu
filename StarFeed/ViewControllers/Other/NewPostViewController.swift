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
        
    var imageView = UIImageView()
    
    private let scrollView = ScrollView()
    private let stackView = TinyView()
    
    private var backButton = BackButton()
    private let titleText = TextField(text: "Title", image: nil)
    private let imageButton = Button(text: "Select a thumbnail...", color: UIColor.theme.blueColor)
    private let videoButton = Button(text: "Select a video...", color: UIColor.theme.blueColor)
    private let videoView = UIButton()
    let nextButton = Button(text: "Next", color: UIColor.theme.blueColor)
    
    var movieURL: URL!

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
            self.navigationController?.pushViewController(NewPostSubjectsViewController(movieURL: self.movieURL, image: self.imageView.image, titleString: self.titleText.text!), animated: true)
        }, for: .touchUpInside)
        nextButton.isEnabled = false

        
        //Scroll View
        view.addSubview(scrollView)
        
        // Stack View
        scrollView.addSubview(stackView)
        stackView.stack([titleText, imageButton, imageView, videoButton, videoView, nextButton], axis: .vertical, width: nil, height: nil, spacing: 10)
        

        
    }
    

    private func setupConstraints() {
        scrollView.edgesToSuperview(excluding: .top)
        scrollView.topToBottom(of: backButton)
        
        stackView.edgesToSuperview(insets: TinyEdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
        stackView.width(view.width - 30)
                
        imageView.heightToWidth(of: stackView, multiplier: 9/16)
        videoView.heightToWidth(of: stackView, multiplier: 9/16)

        
        titleText.height(50)
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
            play.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
            
            view.addSubview(play)
            videoPlayer.addSublayer(play.layer)
            videoView.layer.addSublayer(videoPlayer)
            
        }
    }
}
