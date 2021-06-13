//
//  UserInfoTextField.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/04/25.
//

import UIKit

class UserInfoTextField: UITextField {
    
    init(inputText: String) {
        super.init(frame: .zero)
        
        text = inputText
        textColor = .white
        textAlignment = .left
        font = UIFont.init(name: "GillSans-Light", size: 18)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
