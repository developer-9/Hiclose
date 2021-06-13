//
//  ProfileFooter.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/02/15.
//

import UIKit

protocol ProfileFooterDelegate: class {
    func handleChooseStatus()
}

class ProfileFooter: UIView {
    
    //MARK: - Properties
    
    weak var delegate: ProfileFooterDelegate?
    
    private let chooseStatusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Choose Status🔥", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .mainBlueTint
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 1
        button.layer.shadowOffset = CGSize(width: 1, height: 1)
        button.layer.shadowOpacity = 0.75
        button.addTarget(self, action: #selector(handleChooseStatus), for: .touchUpInside)
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
    
    //MARK: - Helpers
    
    private func configureUI() {
        addSubview(chooseStatusButton)
        chooseStatusButton.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor,
                                  right: rightAnchor, paddingLeft: 16, paddingRight: 16)
        chooseStatusButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    //MARK: - Actions
    
    @objc func handleChooseStatus() {
        delegate?.handleChooseStatus()
    }
}
