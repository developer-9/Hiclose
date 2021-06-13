//
//  SettingCell.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/05/04.
//

import UIKit

///MARK: - AccountCell

class AccountCell: UITableViewCell {
    
    //MARK: - Properties
    
    var viewModel: AccountViewModel? {
        didSet { configure() }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.init(name: "GillSans-Semibold", size: 16)
        return label
    }()
    
    private let iconEmoji: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "GillSans-Light", size: 16)
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
        backgroundColor = .backgroundColor
        
        addSubview(iconEmoji)
        iconEmoji.centerY(inView: self)
        iconEmoji.anchor(left: leftAnchor, paddingLeft: 12)
        
        addSubview(titleLabel)
        titleLabel.anchor(left: iconEmoji.rightAnchor, paddingLeft: 12)
        titleLabel.centerY(inView: self)
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        titleLabel.text = viewModel.description
        iconEmoji.text = viewModel.iconEmoji
    }
}

///MARK: - InfoCell

class InfoCell: UITableViewCell {
    
    //MARK: - Properties
    
    var viewModel: InformationViewModel? {
        didSet { configure() }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.init(name: "GillSans-Semibold", size: 16)
        return label
    }()
    
    private let iconEmoji: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "GillSans-Light", size: 16)
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
        backgroundColor = .backgroundColor
        
        addSubview(iconEmoji)
        iconEmoji.centerY(inView: self)
        iconEmoji.anchor(left: leftAnchor, paddingLeft: 12)
        
        addSubview(titleLabel)
        titleLabel.anchor(left: iconEmoji.rightAnchor, paddingLeft: 12)
        titleLabel.centerY(inView: self)
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        titleLabel.text = viewModel.description
        iconEmoji.text = viewModel.iconEmoji
    }
}

///MARK: - ActionCell

class ActionCell: UITableViewCell {
    
    //MARK: - Properties
    
    var viewModel: ActionsViewModel? {
        didSet { configure() }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.init(name: "GillSans-Semibold", size: 16)
        return label
    }()
    
    private let iconEmoji: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.init(name: "GillSans-Light", size: 16)
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
        backgroundColor = .backgroundColor
        
        addSubview(iconEmoji)
        iconEmoji.centerY(inView: self)
        iconEmoji.anchor(left: leftAnchor, paddingLeft: 12)
        
        addSubview(titleLabel)
        titleLabel.anchor(left: iconEmoji.rightAnchor, paddingLeft: 12)
        titleLabel.centerY(inView: self)
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        titleLabel.text = viewModel.description
        iconEmoji.text = viewModel.iconEmoji
    }
}

