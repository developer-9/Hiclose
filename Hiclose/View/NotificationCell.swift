//
//  NotificationCell.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/05/30.
//

import UIKit

protocol NotificationCellDelegate: class {
    func cell(_ cell: NotificationCell, wantsToAccept uid: String, id: String)
    func cell(_ cell: NotificationCell, wantsToDismiss uid: String, id: String)
    func cell(_ cell: NotificationCell, wantsToViewProfile uid: String)
    func cell(_ cell: NotificationCell, wantsToStartChatWith user: User)
}

class NotificationCell: UITableViewCell {
    
    //MARK: - Properties
    
    weak var delegate: NotificationCellDelegate?
    
    var viewModel: NotificationViewModel? {
        didSet { configure() }
    }
        
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImage))
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(tap)
        return iv
    }()
    
    var infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    lazy var acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("承認", for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.backgroundColor = .systemBlue
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 11)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleAccept), for: .touchUpInside)
        return button
    }()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("拒否", for: .normal)
        button.setTitleColor(.backgroundColor, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 11)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    lazy var chatStartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Chat🔥", for: .normal)
        button.setTitleColor(.backgroundColor, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.white.cgColor
        button.backgroundColor = .white
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleNewMessage), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    
    @objc func handleProfileImage() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, wantsToViewProfile: viewModel.notification.uid)
    }
    
    @objc func handleAccept() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, wantsToAccept: viewModel.notification.uid, id: viewModel.notification.id)
    }
    
    @objc func handleDismiss() {
        guard let viewModel = viewModel else { return }
        delegate?.cell(self, wantsToDismiss: viewModel.notification.uid, id: viewModel.notification.id)
    }
    
    @objc func handleNewMessage() {
        guard let uid = viewModel?.notification.uid else { return }
        UserService.fetchUser(withUid: uid) { user in
            self.delegate?.cell(self, wantsToStartChatWith: user)
        }
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        backgroundColor = .backgroundColor
        contentView.addSubview(profileImageView)
        profileImageView.setDimensions(height: 42, width: 42)
        profileImageView.layer.cornerRadius = 42 / 2
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        
        let stack = UIStackView(arrangedSubviews: [acceptButton, dismissButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        
        contentView.addSubview(stack)
        stack.centerY(inView: self)
        stack.anchor(right: rightAnchor, paddingRight: 12, width: 120, height: 32)
        
        contentView.addSubview(chatStartButton)
        chatStartButton.centerY(inView: self)
        chatStartButton.anchor(right: rightAnchor, paddingRight: 12, width: 120, height: 32)
        chatStartButton.isHidden = true
        
        contentView.addSubview(infoLabel)
        infoLabel.centerY(inView: self)
        infoLabel.anchor(left: profileImageView.rightAnchor, right: rightAnchor,
                         paddingLeft: 10, paddingRight: 140)
    }
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        profileImageView.sd_setImage(with: viewModel.profileImageUrl, completed: nil)
        infoLabel.attributedText = viewModel.notificationMessage
        acceptButton.isHidden = viewModel.shouldHideAcceptStackButton
        dismissButton.isHidden = viewModel.shouldHideAcceptStackButton
        chatStartButton.isHidden = !viewModel.shouldHideAcceptStackButton
    }
}
