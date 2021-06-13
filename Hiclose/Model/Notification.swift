//
//  Notification.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/05/29.
//

import Firebase

enum NotificationType: Int {
    case friendRequest
    case friendAccept
    
    var notificationMessage: String {
        switch self {
        case .friendRequest: return " と友達になりますか？"
        case .friendAccept: return " と友達になりました👏"
        }
    }
}

struct Notification {
    let uid: String
    var timestamp: Timestamp
    let type: NotificationType
    let id: String
    let profileImageUrl: String
    let fullname: String
    
    init(dictionary: [String: Any]) {
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.id = dictionary["id"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.type = NotificationType(rawValue: dictionary["type"] as? Int ?? 0) ?? .friendAccept
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
    }
}
