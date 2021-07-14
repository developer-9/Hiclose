//
//  DummyAccountView.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/06/29.
//

import UIKit

class DummyAccountView: UIView {
    
    //MARK: - Properties
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.setDimensions(height: 60, width: 60)
        iv.layer.cornerRadius = 60 / 2
        return iv
    }()
    
    private lazy var statusView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.setDimensions(height: 30, width: 30)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 1
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.shadowOpacity = 0.5
        view.layer.cornerRadius = 30 / 2
        
        view.addSubview(statusLabel)
        statusLabel.centerY(inView: view)
        statusLabel.centerX(inView: view)
        return view
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    var selectImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "circle")?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = .white
        iv.backgroundColor = .clear
        iv.setDimensions(height: 30, width: 30)
        iv.layer.cornerRadius = 30 / 2
        return iv
    }()
    
    //MARK: - Lifecycle
    
    init(image: UIImage?, name: String, status: String, location: String, bgColor: UIColor) {
        super.init(frame: .zero)
        backgroundColor = bgColor
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.white.cgColor
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowOpacity = 0.92
        setHeight(80)
        
        profileImageView.image = image
        fullnameLabel.text = name
        statusLabel.text = status
        locationLabel.text = location
        
        addSubview(profileImageView)
        profileImageView.centerY(inView: self)
        profileImageView.anchor(left: leftAnchor, paddingLeft: 12)
        
        addSubview(statusView)
        statusView.anchor(left: profileImageView.rightAnchor, bottom: profileImageView.bottomAnchor,
                          paddingLeft: 12)
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, locationLabel])
        stack.axis = .vertical
        stack.spacing = 12
        
        addSubview(stack)
        stack.centerY(inView: self)
        stack.anchor(left: statusView.rightAnchor, paddingLeft: 16)
        
        addSubview(selectImageView)
        selectImageView.centerY(inView: self)
        selectImageView.anchor(right: rightAnchor, paddingRight: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    func imageChange() {
        selectImageView.image = UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysTemplate)
        selectImageView.tintColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
    }
}
