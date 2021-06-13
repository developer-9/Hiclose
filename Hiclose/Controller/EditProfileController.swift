//
//  EditProfileController.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/04/24.
//

import UIKit

protocol EditProfileControllerDelegate: class {
    func updateUserInfoComplete()
}

class EditProfileController: UIViewController {
    
    //MARK: - Properties
    
    private var user: User?
    
    weak var delegate: EditProfileControllerDelegate?
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleEditProfileImage))
        iv.addGestureRecognizer(tap)
        
        let label = UILabel()
        label.text = "EDIT"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.backgroundColor = .init(white: 0.1, alpha: 0.5)
        label.textAlignment = .center
        
        iv.addSubview(label)
        label.centerX(inView: iv)
        label.setDimensions(height: 36, width: 140)
        label.anchor(bottom: iv.bottomAnchor)
        return iv
    }()

    private lazy var nameView: UIView = {
        return UserInfoView(labelText: "Name", textField: nameTextField)
    }()
    
    private lazy var usernameView: UIView = {
        return UserInfoView(labelText: "User Name", textField: usernameTextField)
    }()
    
    private lazy var emailView: UIView = {
        return UserInfoView(labelText: "Email", textField: emailTextField)
    }()
    
    private let nameTextField = UserInfoTextField(inputText: "")
    private let usernameTextField = UserInfoTextField(inputText: "")
    private let emailTextField = UserInfoTextField(inputText: "")
    
    //MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateUserData()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .black
    }
    
    //MARK: - Actions
    
    @objc func backgroundTapped() {
        self.view.endEditing(false)
    }
    
    @objc func handleEditProfileImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func handleDismissal() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleSave() {
        guard let profileImage = profileImageView.image else { return }
        guard let name = nameTextField.text else { return }
        guard let username = usernameTextField.text else { return }
        guard let email = emailTextField.text else { return }
        
        let credentials = EditCredentials(profileImage: profileImage, name: name,
                                          username: username, email: email)
        
        self.showLoader(true)
        
        EditService.updateUserInfo(withCredential: credentials) { error in
            if let error = error {
                print("DEBUG: FAILED TO UPDATE USER INFO \(error.localizedDescription)")
                self.showLoader(false)
                return
            }
            
            self.showLoader(false)
            self.delegate?.updateUserInfoComplete()
        }
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = .backgroundColor
        configureNavigationBar()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tap)
        
        view.addSubview(profileImageView)
        profileImageView.setDimensions(height: 140, width: 140)
        profileImageView.layer.cornerRadius = 140 / 2
        profileImageView.centerX(inView: view)
        profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [nameView, usernameView, emailView])
        stack.axis = .vertical
        stack.spacing = 16
        
        view.addSubview(stack)
        stack.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                     paddingTop: 16, paddingLeft: 16, paddingRight: 16)
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Edit Profile"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self,
                                                           action: #selector(handleDismissal))
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self,
                                                            action: #selector(handleSave))
        navigationItem.rightBarButtonItem?.tintColor = .systemPurple
        navigationController?.navigationBar.barTintColor = .backgroundColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    private func populateUserData() {
        guard let user = self.user else { return }
        nameTextField.text = user.fullname
        usernameTextField.text = user.username
        emailTextField.text = user.email
        
        guard let url = URL(string: user.profileImageUrl) else { return }
        profileImageView.sd_setImage(with: url, completed: nil)
    }
}

extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        profileImageView.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
}
