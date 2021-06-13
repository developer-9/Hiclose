//
//  NewMessageAnimationController.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/04/04.
//

import UIKit

protocol NewMessageAnimationControllerDelegate: class {
    func controller(_ controller: NewMessageAnimationController, wantsToStartChatWith user: User)
}

class NewMessageAnimationController: UIViewController {
    
    //MARK: - Properties
    
    private var user: User?
    
    weak var delegate: NewMessageAnimationControllerDelegate?
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .mainBlueTint
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var circularProgressView: CirclarProgressView = {
        let frame = CGRect(x: 0, y: 0, width: 360, height: 360)
        let cp = CirclarProgressView(frame: frame)
        
        cp.addSubview(profileImageView)
        profileImageView.setDimensions(height: 268, width: 268)
        profileImageView.layer.cornerRadius = 268 / 2
        profileImageView.centerX(inView: cp)
        profileImageView.centerY(inView: cp, constant: 32)
        
        return cp
    }()
    
    private let connectLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        return label
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
        populatingProfileImageView()
        self.perform(#selector(animateProgress), with: nil, afterDelay: 0.3)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .black
    }
    
    //MARK: - Actions
    
    @objc func animateProgress() {
        circularProgressView.animatePulsatingLayer()
        circularProgressView.setProgressWithAnimation(duration: 7, value: 0) {
            self.dismiss(animated: true, completion: nil)
            guard let user = self.user else { return }
            self.delegate?.controller(self, wantsToStartChatWith: user)
        }
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = .backgroundColor
        navigationController?.navigationBar.barStyle = .black
        
        view.addSubview(circularProgressView)
        circularProgressView.setDimensions(height: 360, width: 360)
        circularProgressView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        circularProgressView.centerX(inView: view)
        
        view.addSubview(connectLabel)
        connectLabel.anchor(top: circularProgressView.bottomAnchor, paddingTop: 48)
        connectLabel.centerX(inView: view)
    }
    
    private func populatingProfileImageView() {
        guard let user = user else { return }
        guard let url = URL(string: user.profileImageUrl) else { return }
        profileImageView.sd_setImage(with: url, completed: nil)
        connectLabel.text = "\(user.fullname) とのチャットルームをつくっています🧸"
    }
}
