//
//  UserCellViewModel.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/02/07.
//

import Foundation

struct UserCellViewModel {
    let user: User
    
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    var username: String {
        return user.username
    }
    
    var fullname: String {
        return user.fullname
    }
    
    init(user: User) {
        self.user = user
    }
}
