//
//  CommentModel.swift
//  StarFeed
//
//  Created by Wendy Buhler on 10/23/21.
//

import Foundation

struct Comment {
    let id = UUID()
    let text: String
    let user: User
}
