//
//  NowCell.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/07/02.
//

import UIKit

class NowCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var viewModel: UserCellViewModel? {
        didSet {
            populateProfileImageView()
            fetchStatus()
        }
    }
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .lightGray
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 58 / 2
        iv.setDimensions(height: 60, width: 60)
        iv.layer.borderColor = UIColor.gradientColor(size: CGSize(width: 60, height: 60),
                                                     colors: [.systemPurple, .blue]).cgColor
        iv.layer.borderWidth = 2.25
        return iv
    }()
    
    private lazy var statusView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gradientColor(size: CGSize(width: 24, height: 24),
                                                     colors: [.systemPurple, .blue])
        view.setDimensions(height: 24, width: 24)
        view.layer.cornerRadius = 24 / 2
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 1
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.shadowOpacity = 0.5
        
        view.addSubview(statusLabel)
        statusLabel.centerY(inView: view)
        statusLabel.centerX(inView: view)
        return view
    }()
    
    private var statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "🎉"
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
        guard let uid = viewModel?.user.uid else { return }
        StatusService.fetchStatus(withUid: uid) { status in
            self.statusLabel.text = status.status
        }
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        addSubview(profileImageView)
        profileImageView.centerX(inView: self)
        profileImageView.centerY(inView: self)
        
        addSubview(statusView)
        statusView.anchor(bottom: profileImageView.bottomAnchor, right: profileImageView.rightAnchor)
    }
    
    private func populateProfileImageView() {
        guard let viewModel = viewModel else { return }
        profileImageView.sd_setImage(with: viewModel.profileImageUrl, completed: nil)
    }
}
