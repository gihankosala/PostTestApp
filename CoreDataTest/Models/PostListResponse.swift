//
//  PostListResponse.swift
//  CoreDataTest
//
//  Created by Admin on 3/12/21.
//  Copyright © 2021 Admin. All rights reserved.
//

import Foundation
class PostListResponseElement: Codable {
    let userID, id: Int
    let title, body: String

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case id, title, body
    }

    init(userID: Int, id: Int, title: String, body: String) {
        self.userID = userID
        self.id = id
        self.title = title
        self.body = body
    }
}

typealias PostListResponse = [PostListResponseElement]
