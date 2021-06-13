//
//  NotificationViewModel.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/05/31.
//

import UIKit

struct NotificationViewModel {
    var notification: Notification
    
    init(notification: Notification) {
        self.notification = notification
    }
    
    var profileImageUrl: URL? {
        return URL(string: notification.profileImageUrl)
    }
    
    var timestampString: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: notification.timestamp.dateValue(), to: Date())
    }
    
    var notificationMessage: NSAttributedString {
        let fullname = notification.fullname
        let message = notification.type.notificationMessage
        
        let attributedText = NSMutableAttributedString(string: fullname,
                                                       attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: message,
                                                 attributes: [.font: UIFont.systemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: " \(timestampString ?? "")",
                                                 attributes: [.font: UIFont.systemFont(ofSize: 12),
                                                              .foregroundColor: UIColor.lightGray]))
        return attributedText
    }
    
    var shouldHideAcceptStackButton: Bool {
        return notification.type == .friendAccept
    }    
}
