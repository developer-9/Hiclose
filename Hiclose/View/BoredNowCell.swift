//
//  BoredNowCell.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/07/24.
//

import UIKit

class BoredNowCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    private let backCircleView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var boredNowView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.setDimensions(height: 60, width: 60)
        view.layer.cornerRadius = 60 / 2

        view.addSubview(boredNowLabel)
        boredNowLabel.centerY(inView: view)
        boredNowLabel.centerX(inView: view)

        return view
    }()
    
    private let boredNowLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap Me!"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12.5, weight: .heavy)
        label.numberOfLines = 0
        label.setDimensions(height: 50, width: 50)
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "profileImageTest1")
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
    
    private var statusLabel: UILabel = {
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
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    
    //MARK: - Helpers
    
    private func configureUI() {
        backgroundColor = .backgroundColor
        addSubview(backCircleView)
        backCircleView.centerX(inView: self)
        backCircleView.centerY(inView: self)
        backCircleView.setDimensions(height: 120, width: self.frame.width - 20)
    }
}
