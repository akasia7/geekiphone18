//
//  Post.swift
//  Brio
//
//  Created by 永井　夏樹 on 2019/08/07.
//  Copyright © 2019 nagainatsuki. All rights reserved.
//

import UIKit

class Post {
        
        //  Modelは「設計図」
        //　String型＝文字「1＋2＝12」
        //  Int型＝数字「1＋2＝3」
        var objectId: String
        var user: User
        var roomId: String
        var imageUrl: String
        var text: String
        var createDate: Date
        var isLiked: Bool?
        var comments: [Comment]?
        var likeCount: Int = 0
        
    init(objectId: String, user: User, imageUrl: String, text: String, createDate: Date, roomId: String) {
            self.objectId = objectId
            self.user = user
            self.imageUrl = imageUrl
            self.text = text
            self.createDate = createDate
            self.roomId = roomId
        }
}

