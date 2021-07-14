//
//  Calling.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/06/27.
//

import Firebase

struct Calling {
    let fromUid: String
    let fullname: String
    let profileImageUrl: String
    let id: String
    var timestamp: Timestamp
    
    init(dictionary: [String: Any]) {
        self.fromUid = dictionary["fromUid"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.id = dictionary["id"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
    }
}
