//
//  User.swift
//  Brio
//
//  Created by 永井　夏樹 on 2019/08/07.
//  Copyright © 2019 nagainatsuki. All rights reserved.
//

import UIKit

class User {
    
    //nilを許容しない＝ユーザーID、名前
    var objectId: String
    var userName: String
    
    //nilを許容している＝表示名、紹介文、イメージ画像
    var displayName: String?
    var introduction: String?
    var imageUrl: String?
    
    init(objectId: String, userName: String) {
        self.objectId = objectId
        self.userName = userName
    }
}
