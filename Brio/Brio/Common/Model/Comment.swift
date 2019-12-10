//
//  Comment.swift
//  Brio
//
//  Created by 永井　夏樹 on 2019/08/07.
//  Copyright © 2019 nagainatsuki. All rights reserved.
//

import UIKit

class Comment {
    var postId: String
    var user: User
    var text: String
    var createDate: Date
    
    init(postId: String, user: User, text: String, createDate: Date) {
        self.postId = postId
        self.user = user
        self.text = text
        self.createDate = createDate
    }
}
