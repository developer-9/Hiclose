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
        label.text = "Enter your invite code🔗"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var inputCodeTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 24)
        tf.textColor = .white
        tf.attributedPlaceholder = NSAttributedString(string: "Invited code here..",
                                                      attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        tf.keyboardAppearance = .dark
        tf.layer.cornerRadius = 5
        let dividerView = UIView()
        dividerView.backgroundColor = .white
        tf.addSubview(dividerView)
        dividerView.anchor(top: tf.bottomAnchor, left: tf.leftAnchor, right: tf.rightAnchor,
                           paddingTop: 4, height: 0.75)
        return tf
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    private let showSignUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.right.circle.fill",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 52, weight: .bold))?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.setDimensions(height: 52, width: 52)
        button.layer.cornerRadius = 52 / 2
        button.addTarget(self, action: #selector(handleShowRegistration), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - API
    
    //MARK: - Actions
    
    @objc func handleShowRegistration() {
        print("DEBUG: 😆")
    }
        
    @objc func handleBackgroundTapped() {
        view.endEditing(true)
    }
    
    @objc func handleDismiss() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = .backgroundColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTapped))
        view.addGestureRecognizer(tap)
        
        view.addSubview(backButton)
        backButton.setDimensions(height: 24, width: 24)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                          paddingTop: 16, paddingLeft: 24)
        
        view.addSubview(titleLabel)
        titleLabel.centerX(inView: view)
        titleLabel.anchor(top: backButton.bottomAnchor, paddingTop: 100)
        
        view.addSubview(inputCodeTextField)
        inputCodeTextField.centerX(inView: view)
        inputCodeTextField.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor,
                                  right: view.rightAnchor, paddingTop: 52, paddingLeft: 32,
                                  paddingRight: 32)
        
        view.addSubview(showSignUpButton)
        showSignUpButton.centerX(inView: view)
        showSignUpButton.anchor(top: inputCodeTextField.bottomAnchor, paddingTop: 42)
    }
}
