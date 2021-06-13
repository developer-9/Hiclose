//
//  SettingsViewModel.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/05/04.
//

import UIKit

enum AccountViewModel: Int, CaseIterable {
    case name
    case username
    case email
    
    var description: String {
        switch self {
        case.name: return "Name"
        case .username: return "Username"
        case .email: return "Email"
        }
    }
    
    var iconEmoji: String {
        switch self {
        case .name: return "🙎‍♂️"
        case .username: return "🙎‍♀️"
        case .email: return "✉️"
        }
    }
}

enum InformationViewModel: Int, CaseIterable {
    case privacyPolicy
    case termsOfService
    case MyHicloseVersion
    
    var description: String {
        switch self {
        case .privacyPolicy: return "Privacy Policy"
        case .termsOfService: return "Terms of Service"
        case .MyHicloseVersion: return "My Hiclose Version"
        }
    }
    
    var iconEmoji: String {
        switch self {
        case .privacyPolicy: return "🔒"
        case .termsOfService: return "📃"
        case .MyHicloseVersion: return "🔨"
        }
    }
}

enum ActionsViewModel: Int, CaseIterable {
    case blockedUsers
    case sendFeedback
    case deleteAccount
    case logOut
    
    var description: String {
        switch self {
        case .blockedUsers: return "Blocked Users"
        case .sendFeedback: return "Send Feedback"
        case .deleteAccount: return "Delete Account"
        case .logOut: return "Log Out"
        }
    }
    
    var iconEmoji: String {
        switch self {
        case .blockedUsers: return "🚫"
        case .sendFeedback: return "📤"
        case .deleteAccount: return "👤"
        case .logOut: return "🚪"
        }
    }
}
