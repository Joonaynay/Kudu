//
//  ImagePicker.swift
//  Kudu
//
//  Created by Forrest Buhler on 10/14/21.
//

import UIKit

class ImagePicker: UIImagePickerController {
    
    init(mediaTypes: [String], allowsEditing: Bool) {
        super.init(navigationBarClass: .none, toolbarClass: .none)
        self.mediaTypes = mediaTypes
        self.allowsEditing = allowsEditing
        self.imageExportPreset = .current        
        self.sourceType = .photoLibrary    
    }
        
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
