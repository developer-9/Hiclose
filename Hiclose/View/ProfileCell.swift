//
//  ProfileCell.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/02/15.
//

import UIKit

class ProfileCell: UITableViewCell {
    
    //MARK: - Properties
    
    var viewModel: ProfileViewModel? {
        didSet { configure() }
    }
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.setDimensions(height: 40, width: 40)
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        backgroundColor = .darkGray
        
        let stack = UIStackView(arrangedSubviews: [emojiLabel, titleLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        
        addSubview(stack)
        stack.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        emojiLabel.text = viewModel.emojiLabel
        titleLabel.text = viewModel.description
    }
}
