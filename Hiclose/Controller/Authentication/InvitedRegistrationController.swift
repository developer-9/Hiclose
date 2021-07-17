//
//  InvitedRegistrationController.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/07/17.
//

import UIKit

class InvitedRegistrationController: UIViewController {
    
    //MARK: - Properties
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter your Invite code🔗"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 36)
        label.textAlignment = .center
        return label
    }()
    
    private let inputCodeTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = UIFont.boldSystemFont(ofSize: 32)
        tf.textColor = .white
        tf.backgroundColor = .darkGray
        tf.attributedPlaceholder = NSAttributedString(string: "Invited code here..",
                                                      attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        tf.keyboardAppearance = .dark
        return tf
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 52, weight: .bold))?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.setDimensions(height: 52, width: 52)
        button.layer.cornerRadius = 52 / 2
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - API
    
    //MARK: - Actions
    
    @objc func handleDismiss() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = .backgroundColor
        
        
        
        view.addSubview(dismissButton)
        dismissButton.centerX(inView: view)
        dismissButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 32)
    }
}
