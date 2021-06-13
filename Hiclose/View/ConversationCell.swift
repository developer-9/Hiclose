//
//  ConversationCell.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/02/12.
//

import UIKit

class ConversationCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var conversation: Conversation? {
        didSet {
            populateUserData()
            fetchStatus()
        }
    }
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var statusView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 1
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.shadowOpacity = 0.5
        
        view.addSubview(statusLabel)
        statusLabel.centerY(inView: view)
        statusLabel.centerX(inView: view)
        return view
    }()
    
    var statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.text = "🎉"
        return label
    }()
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        return label
    }()
    
    private let messageTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    private let backCircleView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.1650220131, green: 0.1779798142, blue: 0.1961108123, alpha: 1)
        return view
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    //MARK: - API
    
    private func fetchStatus() {
        guard let conversation = conversation else { return }
        StatusService.fetchStatus(withUid: conversation.user.uid) { status in
            self.statusLabel.text = status.status
        }
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        addSubview(backCircleView)
        backCircleView.centerX(inView: self)
        backCircleView.centerY(inView: self)
        backCircleView.setDimensions(height: 80, width: self.frame.width - 8)
        backCircleView.layer.cornerRadius = 20
        
        addSubview(profileImageView)
        profileImageView.anchor(left: backCircleView.leftAnchor, paddingLeft: 12)
        profileImageView.setDimensions(height: 60, width: 60)
        profileImageView.layer.cornerRadius = 60 / 2
        profileImageView.centerY(inView: backCircleView)
        
        addSubview(statusView)
        statusView.setDimensions(height: 24, width: 24)
        statusView.layer.cornerRadius = 24 / 2
        statusView.anchor(bottom: profileImageView.bottomAnchor, right: profileImageView.rightAnchor)
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, messageTextLabel])
        stack.axis = .vertical
        stack.spacing = 12
        
        addSubview(stack)
        stack.centerY(inView: backCircleView)
        stack.anchor(left: profileImageView.rightAnchor, right: backCircleView.rightAnchor,
                     paddingLeft: 12, paddingRight: 12)
        
        addSubview(timestampLabel)
        timestampLabel.anchor(top: backCircleView.topAnchor, right: backCircleView.rightAnchor,
                              paddingTop: 20, paddingRight: 12)
    }
    
    private func populateUserData() {
        guard let conversation = conversation else { return }
        let viewModel = ConversationViewModel(conversation: conversation)
        
        fullnameLabel.text = conversation.user.fullname
        messageTextLabel.text = conversation.message.text
        timestampLabel.text = viewModel.timestamp
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
    }
}
