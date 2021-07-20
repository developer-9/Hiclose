//
//  User.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/02/07.
//

import CoreLocation

struct User {
    let uid: String
    let profileImageUrl: String
    let username: String
    let fullname: String
    let email: String
    
    var isRequested = false
    var isMyFriend = false
    var location: CLLocation?
    
    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
    }
}
