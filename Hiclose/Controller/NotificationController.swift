//
//  NotificationController.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/05/30.
//

import UIKit
import PanModal
import Firebase

private let headerIdentifier = "HeaderView"
private let cellIdentifier = "NotificationCell"

protocol NotificationControllerDelegate: AnyObject {
    func controller(wantsToStartChatFromNotifController user: User)
}

class NotificationController: UITableViewController {
    
    //MARK: - Properties
    
    weak var delegate: NotificationControllerDelegate?
    
    private var notifications = [Notification]() {
        didSet { tableView.reloadData() }
    }
    private var user: User?
    
    private let notifCell = NotificationCell()
    private let headerView = NotificationHeader()
    private var isShortFormEnabled = true
    private let refresher = UIRefreshControl()
    
    private var ifNoNotifLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Notifications yet👀"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private var ifNoNotifLabel2: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "友達リクエストなどはここに表示されます"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        fetchNotifications()
        notificationsAreExist()
        fetchCurrentUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refresher.tintColor = .systemPurple
    }
    
    //MARK: - API
    
    private func fetchCurrentUser() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        UserService.fetchUser(withUid: currentUid) { user in
            self.user = user
        }
    }
    
    private func fetchNotifications() {
        NotificationService.fetchNotifications { notifications in
            self.notifications = notifications
        }
    }
    
    private func notificationsAreExist() {
        NotificationService.notificationsAreExist { bool in
            self.ifNoNotifLabel.isHidden = !bool
            self.ifNoNotifLabel2.isHidden = !bool
        }
    }
    
    //MARK: - Actions
    
    @objc func handleRefresh() {
        notifications.removeAll()
        fetchNotifications()
        refresher.endRefreshing()
    }
    
    //MARK: - Helpers
    
    private func configureTableView() {
        tableView.backgroundColor = .backgroundColor
        tableView.register(NotificationHeader.self, forHeaderFooterViewReuseIdentifier: headerIdentifier)
        tableView.register(NotificationCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorStyle = .none
        tableView.rowHeight = 60
        
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        refresher.tintColorDidChange()
        tableView.refreshControl = refresher
        
        let stack = UIStackView(arrangedSubviews: [ifNoNotifLabel, ifNoNotifLabel2])
        stack.axis = .vertical
        stack.spacing = 4
        
        tableView.addSubview(stack)
        stack.centerX(inView: tableView)
        stack.anchor(top: tableView.topAnchor, paddingTop: 150)
    }
}

//MMARK: - UITableViewDataSource

extension NotificationController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NotificationCell
        cell.viewModel = NotificationViewModel(notification: notifications[indexPath.row])
        cell.delegate = self
        return cell
    }
}
 
//MARK: - UITableViewDelegate

extension NotificationController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdentifier) as! NotificationHeader
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
}

//MARK: - PanModalPresentable

extension NotificationController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }

    var shortFormHeight: PanModalHeight {
        return isShortFormEnabled ? .contentHeight(440.0) : longFormHeight
    }

    var anchorModalToLongForm: Bool {
        return false
    }

    func shouldPrioritize(panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        let location = panModalGestureRecognizer.location(in: view)
        return headerView.frame.contains(location)
    }

    func willTransition(to state: PanModalPresentationController.PresentationState) {
        guard isShortFormEnabled, case .longForm = state
            else { return }

        isShortFormEnabled = false
        panModalSetNeedsLayoutUpdate()
    }
}

//MARK: - NOtificationCellDelelgate

extension NotificationController: NotificationCellDelegate {
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
    
    func cell(_ cell: NotificationCell, wantsToStartChatWith user: User) {
        delegate?.controller(wantsToStartChatFromNotifController: user)
    }
    
    func cell(_ cell: NotificationCell, wantsToAccept uid: String, id: String) {
        guard let user = user else { return }
        NotificationService.uploadNotification(toUid: uid, fromUser: user, type: .friendAccept) { _ in
            FriendService.deleteFriendRequest(withUid: uid) { _ in
                FriendService.friendAccept(withUid: uid) { _ in
                    NotificationService.deleteNotification(withNotifId: id) { _ in
                        cell.acceptButton.isHidden = true
                        cell.dismissButton.isHidden = true
                        cell.chatStartButton.isHidden = false
                        cell.infoLabel.text = "最初のメッセージを送ろう！"
                    }
                }
            }
        }
    }
    
    func cell(_ cell: NotificationCell, wantsToDismiss uid: String, id: String) {
        NotificationService.deleteNotification(withNotifId: id) { _ in
            guard let uid = cell.viewModel?.notification.uid else { return }
            guard let fullname = cell.viewModel?.notification.fullname else { return }
            FriendService.deleteFriendRequest(withUid: uid) { _ in
                cell.acceptButton.isHidden = true
                cell.dismissButton.isHidden = true
                cell.chatStartButton.isHidden = true
                cell.infoLabel.text = "\(fullname)からのリクエストを拒否しました💭"
            }
        }
    }
    
    func cell(_ cell: NotificationCell, wantsToViewProfile uid: String) {
        print("DEBUG: HANDLE SHOW PROFILE HERE..")
    }
}
