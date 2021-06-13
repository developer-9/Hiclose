//
//  NotificationHeader.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/05/30.
//

import UIKit

class NotificationHeader: UITableViewHeaderFooterView {
    
    //MARK: - Properties
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .left
        label.text = "👻 Notifications"
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        contentView.backgroundColor = .backgroundColor
        
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 22, paddingLeft: 22)
    }
}
