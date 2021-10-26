//
//  PostModel.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/15/21.
//

import UIKit

struct Post: Identifiable {
    var id: String
    var image: UIImage
    var title: String
    var subjects: [String]
    var date: String
    var user: User
    var likes: [String]
    var comments: [Comment]?
    var movie: URL?
}
