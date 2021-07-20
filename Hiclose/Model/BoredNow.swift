//
//  BoredNow.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/07/21.
//

import Foundation

struct BoredNow {
    var boredNow: Bool
    
    init(dictionary: [String: Any]) {
        self.boredNow = dictionary["boredNow"] as? Bool ?? false
    }
}
