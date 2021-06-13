//
//  UserInfoView.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/04/25.
//

import UIKit

class UserInfoView: UIView {
    
    init(labelText: String, textField: UITextField) {
        super.init(frame: .zero)
        textField.keyboardAppearance = .dark
        backgroundColor = .clear
        setHeight(80)
        
        let label = UILabel()
        label.text = labelText
        label.textAlignment = .left
        label.font = UIFont.init(name: "GillSans-Light", size: 16)
        label.textColor = .white
        
        addSubview(label)
        label.anchor(top: topAnchor, left: leftAnchor, paddingTop: 4, paddingLeft: 8)

        addSubview(textField)
        textField.anchor(top: label.bottomAnchor, left: leftAnchor, right: rightAnchor,
                  paddingTop: 24, paddingLeft: 8, paddingRight: 8)
                
        let dividerView = UIView()
        dividerView.backgroundColor = .white
        addSubview(dividerView)
        dividerView.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
                           paddingLeft: 8, paddingRight: 8, height: 0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
