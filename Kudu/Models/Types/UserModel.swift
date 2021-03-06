//
//  UserModel.swift
//  Kudu
//
//  Created by Forrest Buhler on 10/16/21.
//

import UIKit

struct User: Identifiable {
    let id: String
    var username: String
    let name: String?
    var likes: [String]
    var profileImage: UIImage?
    var following: [String]
    var followers: [String]
    var posts: [String]
}
