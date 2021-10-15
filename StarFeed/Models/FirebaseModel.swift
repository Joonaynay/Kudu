//
//  FirebaseModel.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/14/21.
//

import Foundation

class FirebaseModel: ObservableObject {
    
    static let shared = FirebaseModel()
    
    @Published var subjects: [Subject] = [Subject(name: "Business", image: "building.2.fill"), Subject(name: "Politics", image: "building.columns.fill")]
    
}
