//
//  CommentModel.swift
//  Kudu
//
//  Created by Wendy Buhler on 10/23/21.
//

import Foundation

struct Comment: Identifiable {
    let id: String
    let text: String    
    let user: User
    let date: Date
}
