//
//  ProfileController.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/02/13.
//

import UIKit
import Firebase

private let reuseIdentifier = "ProfileCell"

protocol ProfileControllerDelegate: AnyObject {
    func handleLogout()
}

class ProfileController: UITableViewController {
    
    //MARK: - Properties
    
    weak var delegate: ProfileControllerDelegate?
    
    private var user: User? {
        didSet { headerView.user = user }
    }
    
    private lazy var headerView = ProfileHeader(frame: CGRect(x: 0, y: 0,
                                                              width: UIScreen.main.bounds.width,
                                                              height: UIScreen.main.bounds.height / 2))
    private let footerView = ProfileFooter()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchCurrentUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        fetchCurrentUser()
        footerView.frame = CGRect(x: 0, y: view.frame.height - 100, width: view.frame.width, height: 60)
    }
    
    //MARK: - API
    
    private func fetchCurrentUser() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        UserService.fetchUser(withUid: currentUid) { user in
            self.user = user
        }
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        tableView.backgroundColor = .backgroundColor
        tableView.isScrollEnabled = true
        tableView.tableHeaderView = headerView
        headerView.delegate = self
        tableView.register(ProfileCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.rowHeight = 64
        tableView.tableFooterView = footerView
        footerView.delegate = self
    }
}

//MARK: - UITableViewDataSource

extension ProfileController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProfileViewModel.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
                                                 for: indexPath) as! ProfileCell
        let viewModel = ProfileViewModel(rawValue: indexPath.row)
        cell.viewModel = viewModel
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

//MARK: - UITableViewDelegate

extension ProfileController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let viewModel = ProfileViewModel(rawValue: indexPath.row) else { return }
        
        switch viewModel {
        case .blockedFriends: return tbd()
        case .rateUs: return tbd()
        case .compliments: return tbd()
        case .logout:
            let alert = UIAlertController(title: nil, message: "本当にログアウトしますか？",
                                          preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
                self.dismiss(animated: true) {
                    self.delegate?.handleLogout()
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}

//MARK: - ProfileHeaderDelegate

extension ProfileController: ProfileHeaderDelegate {    
    func tapStatus() {
        let controller = ChooseStatusController(collectionViewLayout: UICollectionViewFlowLayout())
        controller.delegate = self
        presentPanModal(controller)
    }
    
    func showSettingsController() {
        let controller = SettingsController()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    func linkShare() {
        guard let user = user else { return }
        let textView = UITextView()
        textView.isSelectable = true
        textView.isEditable = false
        
        let textString = "\(user.fullname)から招待が届いています！\n招待コード🔗(\(user.uid))を入力して今すぐ\(user.fullname)と繋がろう！\n\nさあ、あなたも今日からHicloseをはじめよう🔥"
        let profileImage = UIImage(url: user.profileImageUrl)
        let appUrl = URL(string: "https://apps.apple.com/")!
        
//        let attributedString = NSMutableAttributedString(string: textString)
//        let codeRange = NSString(string: textString).range(of: "INVITATION CODE")
//        let urlRenge = NSString(string: textString).range(of: "HERE")
//
//        attributedString.addAttribute(.link, value: "https://console.firebase.google.com/u/2/project/hiclose-19909/database/hiclose-19909-default-rtdb/data?hl=ja", range: codeRange)
//        attributedString.addAttribute(.link, value: UIApplication.openSettingsURLString, range: urlRenge)
//        textView.attributedText = attributedString
        
        let items = [textString, profileImage, appUrl] as [Any]
        let activityViewController = UIActivityViewController(activityItems: items,
                                                              applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop,
                                                        UIActivity.ActivityType.postToFacebook]
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func presentEditProfileController() {
        guard let user = self.user else { return }
        let controlller = EditProfileController(user: user)
        controlller.delegate = self
        let nav = UINavigationController(rootViewController: controlller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - ProfileFooterDelegate

extension ProfileController: ProfileFooterDelegate {
    func presentGuestAlert() {
        let alert = UIAlertController(title: "✋🏽Oops✋🏽",
                                      message:"この機能を楽しむにはあなたのアカウントを作る必要があります!!",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Sing In", style: .default, handler: { _ in
            let controller = IntroController()
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func handleChooseStatus() {
        let controller = ChooseStatusController(collectionViewLayout: UICollectionViewFlowLayout())
        controller.delegate = self
        presentPanModal(controller)
    }
}

//MARK: - EditProfileControllerDelegate

extension ProfileController: EditProfileControllerDelegate {
    func updateUserInfoComplete() {
        dismiss(animated: true, completion: nil)
        configureUI()
        fetchCurrentUser()
    }
}

//MARK: - ChooseStatusControllerDelegate

extension ProfileController: ChooseStatusControllerDelegate {
    func didSelect(option: Emoji) {
        StatusService.setStatus(withStatus: option.description) { error in
            if let error = error {
                print("DEBUG: FAILED TO SET STATUS \(error.localizedDescription)")
                return 
            }
            self.headerView.fetchStatus()
            self.dismiss(animated: true, completion: nil)
        }
    }
}
