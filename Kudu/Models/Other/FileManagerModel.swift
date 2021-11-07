//
//  FileManagerModel.swift
//  Kudu
//
//  Created by Forrest Buhler on 10/17/21.
//

import UIKit

struct FileManagerModel {
    
    static let shared = FileManagerModel()
    
    func saveImage(image: UIImage, id: String) {
        
        let imageData = image.jpegData(compressionQuality: 1.0)
        
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(id).jpeg") else { return }
        do {
            try imageData?.write(to: path)
            
        } catch let error {
            print("Error writing to data. \(error)")
        }
        
        
    }
    
    func getPath(id: String) -> URL? {
        
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(id).jpeg") else { return nil }
        
        return path

        
    }
    
    
    func getFromFileManager(id: String) -> UIImage? {
        
        guard let path = getPath(id: id)?.path else { return nil }
        
        return UIImage(contentsOfFile: path)
    }
    
    func deleteAllImages() {
        let path =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        do {
            let urls = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            for url in urls {
                if url.pathExtension == "jpeg" || url.pathExtension == "mp3" {
                    try FileManager.default.removeItem(at: url)
                }
            }
        } catch  { print(error) }
    }
}
