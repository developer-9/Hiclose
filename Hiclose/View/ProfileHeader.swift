//
//  ProfileHeader.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/02/13.
//

import UIKit

protocol ProfileHeaderDelegate: class {
    func dismissController()
    func showSettingsController()
    func presentEditProfileController()
    func linkShare()
}

class ProfileHeader: UIView {
    
    //MARK: - Properties
    
    var user: User? {
        didSet {
            populateUserData()
            fetchStatus()
        }
    }
    
    weak var delegate: ProfileHeaderDelegate?
    
    private let gradient = CAGradientLayer()
    
    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "My Profile"
        label.textColor = .white
        label.font = UIFont.init(name: "GillSans-SemiBold", size: 30)
        label.textAlignment = .left
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
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
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28)
        label.text = "🎉"
        return label
    }()

    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "GillSans-SemiBold", size: 20)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "GillSans-Light", size: 14)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let addFriendButton: UIButton = {
        let button = UIButton().profileActionButton(withImage: UIImage(systemName: "person"))
        button.addTarget(self, action: #selector(handleEditProfile), for: .touchUpInside)
        return button
    }()
    
    private let linkButton: UIButton = {
        let button = UIButton().profileActionButton(withImage: UIImage(systemName: "link"))
        button.addTarget(self, action: #selector(handleLink), for: .touchUpInside)
        return button
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton().profileActionButton(withImage: UIImage(systemName: "gear"))
        button.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - API
    
    func fetchStatus() {
        guard let uid = self.user?.uid else { return }
        StatusService.fetchStatus(withUid: uid) { status in
            self.statusLabel.text = status.status
        }
    }
    
    //MARK: - Actions
    
    @objc func handleLink() {
        delegate?.linkShare()
    }
    
    @objc func handleSettings() {
        delegate?.showSettingsController()
    }
    
    @objc func handleDismissal() {
        delegate?.dismissController()
    }
    
    @objc func handleEditProfile() {
        delegate?.presentEditProfileController()
    }
    
    //MARK: - Helpers
    
    private func populateUserData() {
        guard let user = self.user else { return }
        fullnameLabel.text = user.fullname
        usernameLabel.text = user.username
        
        guard let url = URL(string: user.profileImageUrl) else { return }
        profileImageView.sd_setImage(with: url)
    }
    
    private func configureUI() {
        backgroundColor = .backgroundColor
        
        addSubview(dismissButton)
        dismissButton.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor,
                             paddingTop: 8, paddingLeft: 12)
        dismissButton.setDimensions(height: 42, width: 42)
        
        addSubview(titleLabel)
        titleLabel.centerY(inView: dismissButton)
        titleLabel.anchor(left: dismissButton.rightAnchor, paddingLeft: 20)
        
        addSubview(profileImageView)
        profileImageView.setDimensions(height: 120, width: 120)
        profileImageView.layer.cornerRadius = 120 / 2
        profileImageView.centerX(inView: self)
        profileImageView.anchor(top: titleLabel.bottomAnchor, paddingTop: 32)
        
        addSubview(statusView)
        statusView.setDimensions(height: 48, width: 48)
        statusView.layer.cornerRadius = 48 / 2
        statusView.anchor(bottom: profileImageView.bottomAnchor, right: profileImageView.rightAnchor)

        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel])
        stack.axis = .vertical
        stack.spacing = 4
        
        addSubview(stack)
        stack.centerX(inView: self)
        stack.anchor(top: profileImageView.bottomAnchor, paddingTop: 16)
        
        addSubview(settingsButton)
        settingsButton.anchor(top: usernameLabel.bottomAnchor, left: leftAnchor,
                              paddingTop: 12, paddingLeft: 60)
        settingsButton.setDimensions(height: 52, width: 52)
        settingsButton.layer.cornerRadius = 52 / 2
        
        addSubview(addFriendButton)
        addFriendButton.centerX(inView: self)
        addFriendButton.anchor(top: usernameLabel.bottomAnchor, paddingTop: 32)
        addFriendButton.setDimensions(height: 52, width: 52)
        addFriendButton.layer.cornerRadius = 52 / 2
        
        addSubview(linkButton)
        linkButton.anchor(top: usernameLabel.bottomAnchor, right: rightAnchor,
                          paddingTop: 12, paddingRight: 60)
        linkButton.setDimensions(height: 52, width: 52)
        linkButton.layer.cornerRadius = 52 / 2
    }
}
