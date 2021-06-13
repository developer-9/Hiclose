//
//  ProfileViewModel.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/02/15.
//

import Foundation

enum ProfileViewModel: Int, CaseIterable {
    case blockedFriends
    case rateUs
    case compliments
    case logout
    
    var description: String {
        switch self {
        case .blockedFriends: return "Blocked Friends"
        case .rateUs: return "Rate Us"
        case .compliments: return "Compliments"
        case .logout: return "Log Out"
        }
    }
    
    var emojiLabel: String {
        switch self {
        case .blockedFriends: return "🤔"
        case .rateUs: return "❤️"
        case .compliments: return "🦄"
        case .logout: return "🙊"
        }
    }
}
