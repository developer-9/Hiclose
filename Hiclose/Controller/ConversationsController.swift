//
//  ConversationsController.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/01/29.
//

import UIKit
import Firebase
import PanModal
import Indicate

private let reuseIdentifier = "ConversationCell"
private let headerIdentifier = "ConversationHeader"

class ConversationsController: UICollectionViewController {
    
    //MARK: - Properties
    
    private var calling: Calling?
    private let gradientLayer = CAGradientLayer()
    private let refresher = UIRefreshControl()
    private var header = ConversationHeader()
    private var conversations = [Conversation]()
    private var conversationsDictionary = [String : Conversation]()
    
    private lazy var nowCollectionView = NowCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private var layout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionHeadersPinToVisibleBounds = true
        return layout
    }()
    
    private let NotificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🔔", for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(handleNotification), for: .touchUpInside)
        button.setDimensions(height: 42, width: 42)
        button.layer.cornerRadius = 42 / 2
        return button
    }()
    
    private let NewMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("💭", for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(handleNewMessage), for: .touchUpInside)
        button.setDimensions(height: 42, width: 42)
        button.layer.cornerRadius = 42 / 2
        return button
    }()
    
    private let searchFriendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🔍", for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(handleSearchFriend), for: .touchUpInside)
        button.setDimensions(height: 42, width: 42)
        button.layer.cornerRadius = 42 / 2
        return button
    }()
    private let mapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Go to Map 🗺", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.3813195229, green: 0.2757785618, blue: 0.9383082986, alpha: 1)
        button.addTarget(self, action: #selector(handleMap), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateUser()
        configureUI()
        fetchConversations()
        fetchCallingIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .black
        fetchCallingIndicator()
        conversationsDictionary.removeAll()
        fetchConversations()
        nowCollectionView.fetchBoredNowFromMyFriends()
        nowCollectionView.checkMyBoredNowBool()
        nowCollectionView.guestOrNot()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refresher.tintColor = .systemPurple
    }
    
    override func viewDidLayoutSubviews() {
        nowCollectionView.frame = CGRect(x: 0, y: 110, width: view.frame.width, height: 70).integral
        gradientLayer.frame = view.frame
    }
    
    //MARK: - Actions
    
    @objc func handleNotification() {
        let controller = NotificationController(style: .plain)
        controller.delegate = self
        presentPanModal(controller)
    }
    
    @objc func handleNewMessage() {
        let controller = NewMessageController(collectionViewLayout: UICollectionViewFlowLayout())
        controller.delegate = self
        presentPanModal(controller)
    }
    
    @objc func handleSearchFriend() {
        let controller = SearchFriendsController()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    @objc func handleMap() {
        let controller = MapController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleRefresh() {
//        conversations.removeAll()
//        conversationsDictionary.removeAll()
//        fetchConversations()
        nowCollectionView.fetchBoredNowFromMyFriends()
        nowCollectionView.checkMyBoredNowBool()
        nowCollectionView.guestOrNot()
        refresher.endRefreshing()
    }
    
    //MARK: - API
    
    private func deleteIndicator() {
        guard let id = self.calling?.id else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        CallingService.deleteCallingIndicator(withId: id, uid: currentUid) { _ in
        }
    }
    
    private func fetchVideoUser(withUid uid: String, completion: @escaping(User) -> Void) {
        UserService.fetchUser(withUid: uid) { user in
            completion(user)
        }
    }
    
    private func fetchCallingIndicator() {
        CallingService.fetchCallingIndicator { calling in
            self.calling = calling
            self.presentIndicator(byName: calling.fullname)
        }
    }
    
    private func fetchConversations() {
        MessageService.fetchConversations { conversations in
            conversations.forEach { conversation in
                let message = conversation.message
                self.conversationsDictionary[message.chatPartnerId] = conversation
            }

            self.conversations = Array(self.conversationsDictionary.values)
            self.conversations = self.conversations.sorted(by: { $0.message.timestamp.dateValue() > $1.message.timestamp.dateValue() })
            self.collectionView.reloadData()
        }
    }
    
    private func authenticateUser() {
        if Auth.auth().currentUser?.uid == nil {
            presentLoginScreen()
        }
    }
    
    private func logout() {
        do {
            try Auth.auth().signOut()
            presentLoginScreen()
        } catch {
            print("DEBUG: ERROR SIGNING OUT \(error.localizedDescription)")
        }
    }
    
    //MARK: - Helpers
    
    private func presentIndicator(byName: String) {
        let content = Indicate.Content(title: .init(value: "着信があります", alignment: .left),
                                       subtitle: .init(value: byName, alignment: .left),
                                       attachment: .emoji(.init(value: "📞", alignment: .natural)))
        let config = Indicate.Configuration()
            .with(duration: 10)
            .with(dismissed: { _ in
                self.deleteIndicator()
            })
            .with(tap: { controller in
                controller.dismiss()
                self.presentVideoController()
                self.deleteIndicator()
            })
        let controller = Indicate.PresentationController(content: content, configuration: config)
        controller.present(in: view)
    }
    
    private func presentVideoController() {
        guard let fromUid = self.calling?.fromUid else { return }
        fetchVideoUser(withUid: fromUid) { user in
            let controller = VideoController()
            controller.delegate = self
            controller.user = user
            let nav = UINavigationController(rootViewController: controller)
            nav.modalTransitionStyle = .crossDissolve
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }

    private func presentLoginScreen() {
        DispatchQueue.main.async {
            let controller = IntroController()
            controller.delegate = self
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    private func configureUI() {
        configureCollectionView()
        configureGradientLayerView()
        
        collectionView.addSubview(nowCollectionView)
        
        let stack = UIStackView(arrangedSubviews: [NotificationButton, NewMessageButton,
                                                   searchFriendButton])
        stack.axis = .horizontal
        stack.spacing = 12
        
        view.addSubview(stack)
        stack.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor,
                     paddingLeft: 16, paddingBottom: 12)
        
        view.addSubview(mapButton)
        mapButton.setDimensions(height: 42, width: 180)
        mapButton.layer.cornerRadius = 21
        mapButton.centerY(inView: stack)
        mapButton.anchor(right: view.rightAnchor, paddingRight: 12)
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .backgroundColor
        collectionView.collectionViewLayout = layout
        navigationController?.navigationBar.isHidden = true
        collectionView.register(ConversationHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        collectionView.register(ConversationCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        
        nowCollectionView.nowDelegate = self
        
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refresher.tintColorDidChange()
        collectionView.refreshControl = refresher
        refresher.centerX(inView: collectionView)
        refresher.anchor(top: collectionView.safeAreaLayoutGuide.topAnchor, paddingTop: 20)
    }
    
    private func configureGradientLayerView() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.8, 1.1]
        view.layer.addSublayer(gradientLayer)
    }
    
    private func showChatController(forUser user: User) {
        let controller = ChatController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - UICollectionViewDataSource

extension ConversationsController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return conversations.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ConversationCell
        cell.conversation = conversations[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ConversationHeader
        header.delegate = self
        return header
    }
}

//MARK: - UICollectionViewDelegate

extension ConversationsController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = conversations[indexPath.row].user
        showChatController(forUser: user)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension ConversationsController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 88)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 110)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 74, left: 0, bottom: 0, right: 0)
    }
}

//MARK: - NewMessageControllerDelegate

extension ConversationsController: NewMessageControllerDelegate {
    func controller(wantsToStartChatFromNewMessageController user: User) {
        self.dismiss(animated: true, completion: nil)
        let controller = NewMessageAnimationController(user: user)
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
}

//MARK: - ProfileControllerDelegate

extension ConversationsController: ProfileControllerDelegate {
    func handleLogout() {
        logout()
    }
}

//MARK: - ConversationHeaderDelegate

extension ConversationsController: ConversationHeaderDelegate {
    func handleProfile() {
        let controller = ProfileController(style: .insetGrouped)
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
}

//MARK: - NewMessageAnimationControllerDelegate

extension ConversationsController: NewMessageAnimationControllerDelegate {
    func controller(_ controller: NewMessageAnimationController, wantsToStartChatWith user: User) {
        let controller = ChatController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - IntroControllerDelegate

extension ConversationsController: IntroControllerDelegate {
    func configure() {
        configureUI()
        fetchConversations()
    }
}

//MARK: - NotificationControllerDelegate

extension ConversationsController: NotificationControllerDelegate {
    func controller(wantsToStartChatFromNotifController user: User) {
        self.dismiss(animated: true, completion: nil)
        let controller = NewMessageAnimationController(user: user)
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
}

//MARK: - VideoControllerDelegate

extension ConversationsController: VideoControllerDelegate {
    func deleteCallingIndicator() {
        deleteIndicator()
    }
}

//MARK: - NowCollectionViewDelegate

extension ConversationsController: NowCollectionViewDelegate {
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
}
