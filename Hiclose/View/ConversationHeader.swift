//
//  ConversationsHeader.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/02/16.
//

import UIKit
import Firebase
import SDWebImage

protocol ConversationHeaderDelegate: AnyObject {
    func handleProfile()
}

class ConversationHeader: UICollectionReusableView {
    
    //MARK: - Properties
    
    private var user: User? {
        didSet {
            populateProfileImage()
        }
    }
    
    weak var delegate: ConversationHeaderDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Hiclose🔥"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        return label
    }()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .lightGray
        iv.isUserInteractionEnabled = true
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.borderWidth = 0.6
        iv.layer.borderColor = UIColor.white.cgColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleShowProfile))
        iv.addGestureRecognizer(tap)
        return iv
    }()
        
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        fetchCurrentUser()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fetchCurrentUser()
    }
    
    //MARK: - API
    
    private func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserService.fetchUser(withUid: uid) { user in
            self.user = user
        }
    }
    
    //MARK: - Actions
    
    @objc func handleShowProfile() {
        delegate?.handleProfile()
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        backgroundColor = .backgroundColor
        
        addSubview(titleLabel)
        titleLabel.anchor(left: leftAnchor, bottom: bottomAnchor, paddingLeft: 32, paddingBottom: 16)
        
        addSubview(profileImageView)
        profileImageView.setDimensions(height: 40, width: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        profileImageView.centerY(inView: titleLabel)
        profileImageView.anchor(right: rightAnchor, paddingRight: 20)
    }
    
    private func populateProfileImage() {
        guard let user = user else { return }
        guard let url = URL(string: user.profileImageUrl) else { return }
        self.profileImageView.sd_setImage(with: url, completed: nil)
        self.profileImageView.setNeedsLayout()
    }
}
