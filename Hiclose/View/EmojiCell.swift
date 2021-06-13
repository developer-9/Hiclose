//
//  EmojiCell.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/04/27.
//

import UIKit

class EmojiCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32)
        label.textAlignment = .center
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .backgroundColor
        
        addSubview(emojiLabel)
        emojiLabel.centerY(inView: self)
        emojiLabel.centerX(inView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
