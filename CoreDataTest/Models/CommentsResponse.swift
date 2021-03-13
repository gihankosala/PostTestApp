//
//  CommentsResponse.swift
//  CoreDataTest
//
//  Created by Admin on 3/13/21.
//  Copyright © 2021 Admin. All rights reserved.
//

import Foundation

class CommentsResponseElement: Codable {
    let postID, id: Int
    let name, email, body: String

    enum CodingKeys: String, CodingKey {
        case postID = "postId"
        case id, name, email, body
    }

    init(postID: Int, id: Int, name: String, email: String, body: String) {
        self.postID = postID
        self.id = id
        self.name = name
        self.email = email
        self.body = body
    }
}

typealias CommentsResponse = [CommentsResponseElement]
