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
        didSet { populateProfileImageView() }
    }
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .lightGray
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 60 / 2
        iv.setDimensions(height: 60, width: 60)
        iv.layer.borderColor = UIColor.gradientColor(size: CGSize(width: 60, height: 60),
                                                     colors: [.systemPurple, .blue]).cgColor
        iv.layer.borderWidth = 2.25
        return iv
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    //MARK: - Helpers
    
    private func configureUI() {
        addSubview(profileImageView)
        profileImageView.centerX(inView: self)
        profileImageView.centerY(inView: self)
    }
    
    private func populateProfileImageView() {
        guard let viewModel = viewModel else { return }
        profileImageView.sd_setImage(with: viewModel.profileImageUrl, completed: nil)
    }
}
