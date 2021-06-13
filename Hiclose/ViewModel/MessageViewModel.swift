//
//  MessageViewModel.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/02/11.
//

import UIKit

struct MessageViewModel {
    private let message: Message
    
    var messageBackgroundColor: UIColor {
        return message.isFromCurrentUser ? #colorLiteral(red: 0.8719830089, green: 0.6504528754, blue: 1, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    var messageTextColor: UIColor {
        return message.isFromCurrentUser ? .white : #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    }
    
    var rightAnchorActive: Bool {
        return message.isFromCurrentUser
    }
    
    var leftAnchorActive: Bool {
        return !message.isFromCurrentUser
    }
    
    var shouldHideProfileImage: Bool {
        return message.isFromCurrentUser
    }
        
    var imageView: URL? {
        return URL(string: message.imagesUrl[0])
    }
    
    var profileImageUrl: URL? {
        guard let user = message.user else { return nil }
        return URL(string: user.profileImageUrl)
    }
    
    init(message: Message) {
        self.message = message
    }
}
