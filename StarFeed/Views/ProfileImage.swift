//
//  ProfileImage.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/18/21.
//

import UIKit

class ProfileImage: UIImageView {
    
    init(image: UIImage) {
        super.init(image: image)        
        layer.borderWidth = 1.0
        layer.masksToBounds = false
        layer.cornerRadius = self.frame.size.height/2
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
