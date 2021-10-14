//
//  ImagePickder.swift
//  The Real Ish
//
//  Created by Wendy Buhler on 9/18/21.
//

import SwiftUI
import MobileCoreServices
import AVKit

struct ImagePickerView: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    @Binding var movie: URL?
    let mediaTypes: [String]
        
    @Environment(\.presentationMode) var pres
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        if mediaTypes == ["public.image"] {
            picker.allowsEditing = true
        }
        picker.videoQuality = .typeLow
        picker.videoExportPreset = AVAssetExportPreset640x480
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        uiViewController.sourceType = .photoLibrary
        uiViewController.mediaTypes = mediaTypes
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
                        
            
            if let uiImage = info[.editedImage] as? UIImage {
                
                if let jpegData = uiImage.jpegData(compressionQuality: 0.25) {
                    let jpegImage = UIImage(data: jpegData)
                    parent.image = jpegImage
                }
                
            } else if info[.mediaType] as! String == "public.movie" {
                print("MOVIE")
                if let movieURL = info[.mediaURL] as? URL {
                    parent.movie = movieURL
                }
            }
            
            parent.pres.wrappedValue.dismiss()
        }
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}
