//
//  SearchUserProfileController.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/05/27.
//

import UIKit
import PanModal
import Firebase

class SearchUserProfileController: UIViewController {
    
    //MARK: - Properties
    
    var viewModel: SearchUserProfileViewModel? {
        didSet { configureRequestButton() }
    }
    
    private var guestBool: Bool!
    private var currentUser: User!
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()

    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        return label
    }()
    
    private lazy var friendRequestButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemPurple
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitle("Loading", for: .normal)
        button.setHeight(50)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemPurple.cgColor
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(handleFriendRequest), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle

//    init(user: User) {
//        self.user = user
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        populateUserData()
        checkIfUserIsRequested()
        fetchCurrentUser()
        guestOrNot()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - API
    
    private func guestOrNot() {
        UserService.guestOrNot { bool in
            self.guestBool = bool
        }
    }
    
    private func fetchCurrentUser() {
        guard let currentUser = Auth.auth().currentUser?.uid else { return }
        UserService.fetchUser(withUid: currentUser) { user in
            self.currentUser = user
        }
    }
    
    private func checkIfUserIsRequested() {
        guard let user = viewModel?.user else { return }
        FriendService.checkIfUserIsRequested(uid: user.uid) { isRequested in
            self.viewModel?.user.isRequested = isRequested
            self.view.reloadInputViews()
        }
    }
    
    //MARK: - Actions
    
    @objc func handleFriendRequest() {
        if self.guestBool {
            guestAlert()
        } else {
            guard viewModel?.user.isRequested == false else { return }
            guard let uid = viewModel?.user.uid else { return }
            FriendService.friendRequest(withUid: uid) { error in
                self.viewModel?.user.isRequested = true
                self.configureRequestButton()
                NotificationService.uploadNotification(toUid: uid, fromUser: self.currentUser,
                                                       type: .friendRequest) { error in
                    if let error = error {
                        print("DEBUG: FAILED TO UPLOAD NOTIFICATION \(error.localizedDescription)")
                        return
                    }
                }
            }
        }
        
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(profileImageView)
        profileImageView.setDimensions(height: 120, width: 120)
        profileImageView.layer.cornerRadius = 120 / 2
        profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        profileImageView.centerX(inView: view)
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel])
        stack.axis = .vertical
        stack.spacing = 6
        
        view.addSubview(stack)
        stack.anchor(top: profileImageView.bottomAnchor, paddingTop: 12)
        stack.centerX(inView: profileImageView)
        
        view.addSubview(friendRequestButton)
        friendRequestButton.anchor(top: stack.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                             paddingTop: 24, paddingLeft: 24, paddingRight: 24)
    }
    
    private func populateUserData() {
        guard let user = viewModel?.user else { return }
        guard let url = URL(string: user.profileImageUrl) else { return }
        fullnameLabel.text = user.fullname
        usernameLabel.text = user.username
        profileImageView.sd_setImage(with: url, completed: nil)
    }
    
    private func configureRequestButton() {
        guard let viewModel = viewModel else { return }
        friendRequestButton.setTitle(viewModel.requestButtonText, for: .normal)
        friendRequestButton.setTitleColor(viewModel.requestButtonTextColor, for: .normal)
        friendRequestButton.backgroundColor = viewModel.requestButtonBackgroundColor
    }
}

//MARK: - PanModalPresentable

extension SearchUserProfileController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }

    var shortFormHeight: PanModalHeight {
        return .contentHeight(320)
    }
    
    var longFormHeight: PanModalHeight {
        return .contentHeight(320)
    }

    var anchorModalToLongForm: Bool {
        return false
    }
    
    var showDragIndicator: Bool {
        return false
    }
}

