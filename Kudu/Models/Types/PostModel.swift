//
//  PostModel.swift
//  Kudu
//
//  Created by Forrest Buhler on 10/15/21.
//

import UIKit

struct Post: Identifiable {
    var id: String
    var image: UIImage
    var title: String
    var subjects: [String]
    var date: Date
    var uid: String
    var comments: [Comment]?
    var likeCount: Int
    var movie: URL?
    var description: String?
}
