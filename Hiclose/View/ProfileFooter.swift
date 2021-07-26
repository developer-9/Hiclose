//
//  ProfileFooter.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/02/15.
//

import UIKit

protocol ProfileFooterDelegate: AnyObject {
    func handleChooseStatus()
    func presentGuestAlert()
}

class ProfileFooter: UIView {
    
    //MARK: - Properties
    
    weak var delegate: ProfileFooterDelegate?
    private var guestBool: Bool!
    
    private lazy var chooseStatusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Choose Status🔥", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = #colorLiteral(red: 0.6068018079, green: 0.2939791679, blue: 0.8860545158, alpha: 1)
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
        guestOrNot()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guestOrNot()
    }
    
    //MARK: - API
    
    private func guestOrNot() {
        UserService.guestOrNot { bool in
            self.guestBool = bool
        }
    }
    
    //MARK: - Actions
    
    @objc func handleChooseStatus() {
        if self.guestBool {
            delegate?.presentGuestAlert()
        } else {
            delegate?.handleChooseStatus()
        }
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        backgroundColor = .backgroundColor
        addSubview(chooseStatusButton)
        chooseStatusButton.anchor(left: leftAnchor, bottom: bottomAnchor,
                                  right: rightAnchor, paddingLeft: 16, paddingRight: 16, height: 60)
//        chooseStatusButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
}
