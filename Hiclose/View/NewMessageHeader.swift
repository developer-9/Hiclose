//
//  NewMessageHeader.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/03/22.
//

import UIKit

class NewMessageHeader: UICollectionReusableView {
    
    //MARK: - Properties
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        label.textAlignment = .left
        label.text = "🙌🏼  Hiclose Friends"
        return label
    }()

    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        backgroundColor = .backgroundColor
        
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 22, paddingLeft: 22)
    }
}
