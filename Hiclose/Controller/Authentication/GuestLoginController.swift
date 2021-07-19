//
//  GuestLoginController.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/06/28.
//

import UIKit

class GuestLoginController: UIViewController {
    
    //MARK: - Properties
    
    weak var delegate: AuthenticationDelegate?
    
    private let titleLabel1: UILabel = {
        let label = UILabel()
        label.text = "Let's try"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .left
        return label
    }()
    
    private let titleLabel2: UILabel = {
        let label = UILabel()
        label.text = "Guest Login😶‍🌫️"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var dummyAccount1 = DummyAccountView(image: #imageLiteral(resourceName: "dummy2"), name: "Noah Johnson", status: "❤️‍🔥",
                                                      location: "📍 USA, LosAngels 302",
                                                      bgColor: .twitterBlue)
    private lazy var dummyAccount2 = DummyAccountView(image: #imageLiteral(resourceName: "dummy1"), name: "Ava Smith", status: "🎧",
                                                      location: "📍 USA, LosAngels 302",
                                                      bgColor: #colorLiteral(red: 0.8719830089, green: 0.6504528754, blue: 1, alpha: 1))
    private lazy var dummyAccount3 = DummyAccountView(image: #imageLiteral(resourceName: "dummy3"), name: "Rebecca Morris", status: "🍻",
                                                      location: "📍 USA, LosAngels 302",
                                                      bgColor: .twitterBlue)
    
    private let explainLabel: UILabel = {
        let label = UILabel()
        label.text = "のぞいてみたい友達を選んでHicloseを体験してみよう！"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        return label
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - API
    
    private func dummyAccountLogin(username: String) {
        showLoader(true)
        AuthService.dummyAccountLogin(withUsername: username) { result, error in
            if let error = error {
                print("DEBUG: FAILED TO LOG USER IN \(error.localizedDescription)")
                self.showLoader(false)
                self.showError(error.localizedDescription)
                return
            }
            self.showLoader(false)
            self.delegate?.authenticationComplete()
        }
    }
    
    //MARK: - Actions
    
    @objc func handleDismiss() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func tapped1() {
        dummyAccount1.imageChange()
        dummyAccountLogin(username: "noah")
    }
    
    @objc func tapped2() {
        dummyAccount2.imageChange()
        dummyAccountLogin(username: "ava")
    }
    
    @objc func tapped3() {
        dummyAccount3.imageChange()
        dummyAccountLogin(username: "rebecca")
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = .backgroundColor
        
        let titleStack = UIStackView(arrangedSubviews: [titleLabel1, titleLabel2])
        titleStack.axis = .vertical
        titleStack.spacing = 8
        
        view.addSubview(titleStack)
        titleStack.centerX(inView: view)
        titleStack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                          paddingTop: 42, paddingLeft: 42)
        
        let accountStack = UIStackView(arrangedSubviews: [dummyAccount1, dummyAccount2, dummyAccount3])
        accountStack.axis = .vertical
        accountStack.spacing = 30
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(tapped1))
        dummyAccount1.addGestureRecognizer(tap1)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(tapped2))
        dummyAccount2.addGestureRecognizer(tap2)
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(tapped3))
        dummyAccount3.addGestureRecognizer(tap3)
        
        view.addSubview(accountStack)
        accountStack.centerX(inView: view)
        accountStack.anchor(top: titleStack.bottomAnchor, left: view.leftAnchor,
                             right: view.rightAnchor, paddingTop: 64, paddingLeft: 24, paddingRight: 24)
        
        view.addSubview(explainLabel)
        explainLabel.centerX(inView: view)
        explainLabel.anchor(top: accountStack.bottomAnchor, paddingTop: 48)
        
        view.addSubview(dismissButton)
        dismissButton.centerX(inView: view)
        dismissButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 32)
    }
}
