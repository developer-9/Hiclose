//
//  LoginController.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/01/30.
//

import UIKit

protocol AuthenticationDelegate: AnyObject {
    func authenticationComplete()
}

class LoginController: UIViewController {
    
    //MARK: - Properties
    
    weak var delegate: AuthenticationDelegate?
    private var viewModel = LoginViewModel()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Hiclose🔥"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 42, weight: .semibold)
        label.alpha = 0
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to"
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.alpha = 0
        return label
    }()
    
    private lazy var emailContainerView: UIView = {
       return InputContainerView(image: #imageLiteral(resourceName: "ic_mail_outline_white_2x"), textField: emailTextField)
    }()
    
    private lazy var passwordContainerView: UIView = {
       return InputContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
    }()
    
    private let emailTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Email")
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    private let passwordTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        button.setTitleColor(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1), for: .normal)
        button.layer.cornerRadius = 50 / 2
        button.layer.borderWidth = 2.5
        button.setHeight(50)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    private let haveAnInviteCodeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Have an invite code? →", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleShowInvitedSignUp), for: .touchUpInside)
        return button
    }()
    
    private let guestLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Let's try Guest Login😶‍🌫️", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .clear
        button.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        button.layer.cornerRadius = 50 / 2
        button.layer.borderColor = UIColor.gradientColor(size: CGSize(width: 120, height: 50),
                                                         colors: [.cyan, .magenta]).cgColor
        button.layer.borderWidth = 2
        button.setHeight(50)
        button.addTarget(self, action: #selector(handleGuestLogin), for: .touchUpInside)
        button.alpha = 0
        return button
    }()
    
    private let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "まだアカウントを持っていません ", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.white])
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.white]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNotificationObservers()
    }
    
    //MARK: - Actions
    
    @objc func handleShowInvitedSignUp() {
        let controller = InvitedRegistrationController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleGuestLogin() {
        let controller = GuestLoginController()
        controller.delegate = delegate
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        showLoader(true)
        
        AuthService.logUserIn(withEmail: email, password: password) { (result, error) in
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
    
    @objc func handleShowSignUp() {
        let controller = RegistrationController()
        controller.delegate = delegate
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func backgroundTapped() {
        self.view.endEditing(false)
    }
    
    @objc func textDidChanged(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else {
            viewModel.password = sender.text
        }
        updateForm()
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        view.backgroundColor = .backgroundColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tap)
        
        let titleStack = UIStackView(arrangedSubviews: [subTitleLabel, titleLabel])
        titleStack.axis = .vertical
        titleStack.spacing = 8
        
        view.addSubview(titleStack)
        titleStack.centerX(inView: view)
        titleStack.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        UIView.animate(withDuration: 4.2) {
            self.subTitleLabel.alpha = 1
        }
        
        UIView.animate(withDuration: 8.2) {
            self.titleLabel.alpha = 1
        }
        
        let inputStack = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView,
                                                        loginButton])
        inputStack.axis = .vertical
        inputStack.spacing = 16
        
        view.addSubview(inputStack)
        inputStack.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                          paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(haveAnInviteCodeButton)
        haveAnInviteCodeButton.anchor(top: loginButton.bottomAnchor, right: view.rightAnchor,
                                      paddingTop: 6, paddingRight: 42)
        
        view.addSubview(guestLoginButton)
        guestLoginButton.centerX(inView: view)
        guestLoginButton.anchor(top: haveAnInviteCodeButton.bottomAnchor, left: view.leftAnchor,
                                right: view.rightAnchor, paddingTop: 72, paddingLeft: 52,
                                paddingRight: 52)
        
        UIView.animate(withDuration: 8.2) {
            self.guestLoginButton.alpha = 1
        }
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(left: view.leftAnchor,
                                     bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                     right: view.rightAnchor, paddingLeft: 32, paddingRight: 32)
    }
    
    private func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChanged), for: .editingChanged)
    }
}

//MARK: - FormViewModel

extension LoginController: FormViewModel {
    func updateForm() {
        loginButton.backgroundColor = viewModel.buttonBackgroundColor
        loginButton.layer.borderColor = viewModel.buttonBorderColor.cgColor
        loginButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        loginButton.isEnabled = viewModel.formIsValid
    }
}
