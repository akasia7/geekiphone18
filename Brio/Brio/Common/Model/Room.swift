//
//  Room.swift
//  Brio
//
//  Created by 駿妹尾 on 8/9/31 H.
//  Copyright © 31 Heisei nagainatsuki. All rights reserved.
//

import Foundation
import NCMB

struct Room {
    var id: String
    var name: String
    var artistId: String?
    var description: String?
    var userIds: [String]
    var createdUserId: String
    var imageUrl: String?
    var createdAt: Date?
    var isJoined: Bool {
        guard let currentUser = NCMBUser.current() else { return false }
        return userIds.contains(currentUser.objectId)
    }
    
    init(id: String, name: String, description: String?, artistId: String?, userIds: [String], createdUserId: String, imageUrl: String? ) {
        self.id = id
        self.name = name
        self.description = description
        self.artistId = artistId
        self.userIds = userIds
        self.createdUserId = createdUserId
        self.imageUrl = imageUrl
    }
    
    enum field: String {
        case name = "name"
        case artistId = "artistId"
        case description = "description"
        case userIds = "userIds"
        case createdUserId = "createdUserId"
        case imageUrl = "imageUrl"
    }
    
    
    // Roomを持ってくるメソッド
    static func fetchRooms(limit: Int32 = 100,
                         skip: Int32? = nil,
                         searchName: String? = nil,
                         searchArtistId: String? = nil,
                         userIds: [String]? = nil,
                         completion: @escaping([Room]?, Error?) -> ()){
        guard NCMBUser.current() != nil else { completion(nil, nil); return }
        let query = NCMBQuery(className: "Room")
        query?.limit = limit
        if let userIds = userIds {
            query?.whereKey(field.userIds.rawValue, containedInArrayTo: userIds)
            //query?.whereKey(field.userIds.rawValue, containedIn: userIds)
        }
        if let skip   = skip   { query?.skip = skip }
        if let searchName   = searchName   { query?.whereKey(field.name.rawValue, equalTo: ["$regex": searchName]) }
        if let searchArtist   = searchArtistId   { query?.whereKey(field.artistId.rawValue, equalTo: ["$regex": searchArtist]) }
        query?.findObjectsInBackground({ (objects, error) in
            guard error == nil else { completion(nil, error); return }
            var rooms = [Room]()
            for object in objects as! [NCMBObject] {
            
                guard let id = object.objectId else { completion(nil, nil); return }
                guard let name = object.object(forKey: field.name.rawValue) else { completion(nil, nil); return }
                let artistId = object.object(forKey: field.artistId.rawValue) as! String?
                let description = object.object(forKey: field.description.rawValue) as! String?
                let userIds = object.object(forKey: field.userIds.rawValue) as! [String]
                let createdUserId = object.object(forKey: field.createdUserId.rawValue) as! String
                let imageUrl = object.object(forKey: field.imageUrl.rawValue) as! String?
                let room: Room = .init(id: id, name: name as! String, description: description!, artistId: artistId, userIds: userIds, createdUserId: createdUserId, imageUrl: imageUrl)
                rooms.append(room)
            }
            completion(rooms, nil)
        })

        
    }
    
    // Roomを作るメソッド
    static func create(name: String,
                       description: String?,
                       completion: @escaping(Error?) -> ()){
        guard let user = NCMBUser.current() else { completion(nil); return }
        guard let room = NCMBObject(className: "Room") else { completion(nil); return }
        room.setObject(name, forKey: field.name.rawValue)
        if description != nil {
            room.setObject(description, forKey: field.description.rawValue)
        }
        room.setObject(user.objectId, forKey: field.createdUserId.rawValue)
        room.setObject([user.objectId], forKey: field.userIds.rawValue)
        room.saveInBackground { (error) in
            guard error == nil else { completion( error) ; return }
            completion(error)
        }
        
    }
    
}
