//
//  SearchUserProfileViewModel.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/05/28.
//

import UIKit

struct SearchUserProfileViewModel {
    var user: User
    
    var requestButtonText: String {
        if user.isMyFriend {
            return "すでに友達です🤝"
        }
        return user.isRequested ? "友達の承認待ち🙌" : "友達リクエストを送る👋"
    }
    
    var requestButtonBackgroundColor: UIColor {
        if user.isMyFriend {
            return .white
        }
        return user.isRequested ? .white : .systemPurple
    }
    
    var requestButtonTextColor: UIColor {
        if user.isMyFriend {
            return .backgroundColor
        }
        return user.isRequested ? .systemPurple : .white
    }
    
    init(user: User) {
        self.user = user
    }
}
