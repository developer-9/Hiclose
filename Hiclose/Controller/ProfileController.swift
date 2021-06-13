//
//  ProfileController.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/02/13.
//

import UIKit
import Firebase

private let reuseIdentifier = "ProfileCell"

protocol ProfileControllerDelegate: class {
    func handleLogout()
}

class ProfileController: UITableViewController {
    
    //MARK: - Properties
    
    weak var delegate: ProfileControllerDelegate?
    private var user: User? {
        didSet { headerView.user = user }
    }
    private lazy var headerView = ProfileHeader(frame: .init(x: 0, y: 0,
                                                        width: view.frame.width, height: 420))
    private let footerView = ProfileFooter()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
        
    //MARK: - API
    
    private func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserService.fetchUser(withUid: uid) { user in
            self.user = user
        }
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        tableView.backgroundColor = .backgroundColor
        tableView.isScrollEnabled = false
        tableView.tableHeaderView = headerView
        headerView.delegate = self
        tableView.register(ProfileCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.rowHeight = 64
        
        footerView.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
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
            let alert = UIAlertController(title: nil, message: "本当にログアウトしますか？", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
                self.dismiss(animated: true) {
                    self.delegate?.handleLogout()
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }    
}

//MARK: - ProfileHeaderDelegate

extension ProfileController: ProfileHeaderDelegate {
    func showSettingsController() {
        let controller = SettingsController()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    func linkShare() {
        let text = "Let's share Hiclose and tell your best friend about it🔥"
        let textToShare = [text]
        let activityViewController = UIActivityViewController(activityItems: textToShare,
                                                              applicationActivities: nil)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop,
                                                         UIActivity.ActivityType.postToFacebook ]
        
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
        fetchUser()
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
