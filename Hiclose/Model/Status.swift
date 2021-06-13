//
//  Status.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/04/28.
//

import Foundation

struct Status {
    let status: String
    let uid: String
    
    init(dictionary: [String: Any]) {
        self.status = dictionary["status"] as? String ?? "🎉"
        self.uid = dictionary["uid"] as? String ?? ""
    }
}
