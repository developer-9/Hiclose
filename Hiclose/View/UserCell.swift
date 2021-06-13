//
//  UserCell.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/02/07.
//

import UIKit
import SDWebImage

class UserCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var viewModel: UserCellViewModel? {
        didSet {
            populateUserData()
            fetchStatus()
        }
    }
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .lightGray
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
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "🎉"
        return label
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 14)
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
    
    //MARK: - API
    
    private func fetchStatus() {
        guard let viewModel = viewModel else { return }
        StatusService.fetchStatus(withUid: viewModel.user.uid) { status in
            self.statusLabel.text = status.status
        }
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        addSubview(profileImageView)
        profileImageView.setDimensions(height: 80, width: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        profileImageView.centerX(inView: self)
        profileImageView.centerY(inView: self)
        
        addSubview(fullnameLabel)
        fullnameLabel.centerX(inView: profileImageView)
        fullnameLabel.anchor(top: profileImageView.bottomAnchor, paddingTop: 8)
        
        addSubview(statusView)
        statusView.setDimensions(height: 30, width: 30)
        statusView.layer.cornerRadius = 30 / 2
        statusView.anchor(bottom: profileImageView.bottomAnchor, right: profileImageView.rightAnchor)
    }
    
    private func populateUserData() {
        guard let viewModel = viewModel else { return }
        fullnameLabel.text = viewModel.fullname
        profileImageView.sd_setImage(with: viewModel.profileImageUrl, completed: nil)
    }
}
