//
//  FriendProfileController.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/04/11.
//

import UIKit
import PanModal
import Firebase

class FriendProfileController: UIViewController {
    
    //MARK: - Properties
    
    private var user: User? {
        didSet { fetchStatus() }
    }
    
    private var isShortFormEnabled = true
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
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
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "🎉"
        return label
    }()
    private let fullnameLabel: UILabel = {
        let label = UILabel()
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
    
    private let callButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setTitle("Call", for: .normal)
        button.setTitleColor(.systemPurple, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setHeight(50)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemPurple.cgColor
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let videoButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemPurple
        button.setTitle("Video", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setHeight(50)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemPurple.cgColor
        button.layer.cornerRadius = 10
        return button
    }()
    
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
        configureUI()
        populateUserData()
        fetchStatus()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Actions
    
    //MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(profileImageView)
        profileImageView.setDimensions(height: 120, width: 120)
        profileImageView.layer.cornerRadius = 120 / 2
        profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        profileImageView.centerX(inView: view)
        
        view.addSubview(statusView)
        statusView.setDimensions(height: 40, width: 40)
        statusView.layer.cornerRadius = 40 / 2
        statusView.anchor(bottom: profileImageView.bottomAnchor, right: profileImageView.rightAnchor)
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel])
        stack.axis = .vertical
        stack.spacing = 6
        
        view.addSubview(stack)
        stack.anchor(top: profileImageView.bottomAnchor, paddingTop: 12)
        stack.centerX(inView: profileImageView)
        
        let buttonStack = UIStackView(arrangedSubviews: [callButton, videoButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 24
        buttonStack.distribution = .fillEqually
        
        view.addSubview(buttonStack)
        buttonStack.anchor(top: stack.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                           paddingTop: 24, paddingLeft: 24, paddingRight: 24)
    }
    
    private func fetchStatus() {
        guard let uid = self.user?.uid else { return }
        StatusService.fetchStatus(withUid: uid) { status in
            self.statusLabel.text = status.status
            print("DEBUG: STATUS IS \(status.status)")
        }
    }
    
    private func populateUserData() {
        guard let user = self.user else { return }
        guard let url = URL(string: user.profileImageUrl) else { return }
        fullnameLabel.text = user.fullname
        usernameLabel.text = user.username
        profileImageView.sd_setImage(with: url, completed: nil)
    }
}

//MARK: - PanModalPresentable

extension FriendProfileController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }

    var shortFormHeight: PanModalHeight {
        return isShortFormEnabled ? .contentHeight(320.0) : longFormHeight
    }

    var anchorModalToLongForm: Bool {
        return false
    }

    func shouldPrioritize(panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        let location = panModalGestureRecognizer.location(in: view)
        return view.frame.contains(location)
    }

    func willTransition(to state: PanModalPresentationController.PresentationState) {
        guard isShortFormEnabled, case .longForm = state
            else { return }

        isShortFormEnabled = false
        panModalSetNeedsLayoutUpdate()
    }
}
