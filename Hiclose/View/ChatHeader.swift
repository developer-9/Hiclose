//
//  ChatHeader.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/02/08.
//

import UIKit

protocol ChatHeaderDelegate: class {
    func header(_ chatHeader: ChatHeader)
    func header(_ chatHeader: ChatHeader, showProfileWith user: User)
}

class ChatHeader: UICollectionReusableView {
    
    //MARK: - Properties
    
    var viewModel: UserCellViewModel? {
        didSet {
            populateUserData()
            fetchStatus()
        }
    }
    
    weak var delegate: ChatHeaderDelegate?
    
    private lazy var headerProfileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageView))
        iv.addGestureRecognizer(tap)
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
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "🎉"
        return label
    }()

    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
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
        guard let viewModel = viewModel else { return }
        StatusService.fetchStatus(withUid: viewModel.user.uid) { status in
            self.statusLabel.text = status.status
        }
    }
    
    //MARK: - Actions
    
    @objc func handleProfileImageView() {
        guard let viewModel = viewModel else { return }
        delegate?.header(self, showProfileWith: viewModel.user)
    }
    
    @objc func handleDismissal() {
        delegate?.header(self)
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        backgroundColor = .backgroundColor
        
        addSubview(headerProfileImageView)
        headerProfileImageView.centerX(inView: self)
        headerProfileImageView.anchor(bottom: bottomAnchor, paddingBottom: 12)
        headerProfileImageView.setDimensions(height: 42, width: 42)
        headerProfileImageView.layer.cornerRadius = 42 / 2
        
        addSubview(statusView)
        statusView.setDimensions(height: 24, width: 24)
        statusView.layer.cornerRadius = 24 / 2
        statusView.anchor(left: headerProfileImageView.rightAnchor,
                           bottom: headerProfileImageView.bottomAnchor, paddingLeft: 16)
        
        addSubview(backButton)
        backButton.setDimensions(height: 24, width: 24)
        backButton.centerY(inView: headerProfileImageView)
        backButton.anchor(left: leftAnchor, paddingLeft: 16)

    }
    
    private func populateUserData() {
        guard let viewModel = viewModel else { return }
        headerProfileImageView.sd_setImage(with: viewModel.profileImageUrl, completed: nil)
    }
}
