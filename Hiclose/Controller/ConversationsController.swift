//
//  ConversationsController.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/01/29.
//

import UIKit
import Firebase
import PanModal

private let reuseIdentifier = "ConversationCell"
private let headerIdentifier = "ConversationHeader"

class ConversationsController: UICollectionViewController {
    
    //MARK: - Properties
    
    private var header = ConversationHeader()
        
    private var conversations = [Conversation]() {
        didSet { collectionView.reloadData() }
    }
    
    private var conversationsDictionary = [String : Conversation]()
    
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
        button.backgroundColor = #colorLiteral(red: 0.8719830089, green: 0.6504528754, blue: 1, alpha: 1)
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .black
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
    
    //MARK: - API
    
    private func fetchConversations() {
        MessageService.fetchConversations { conversations in
            conversations.forEach { conversation in
                let message = conversation.message
                self.conversationsDictionary[message.chatPartnerId] = conversation
            }
            self.conversations = Array(self.conversationsDictionary.values)
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
            print("DEBUG: ERROR SIGNING OUT")
        }
    }
    
    //MARK: - Helpers
    
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
        
        let stack = UIStackView(arrangedSubviews: [NotificationButton, NewMessageButton,
                                                   searchFriendButton])
        stack.axis = .horizontal
        stack.spacing = 12
        
        collectionView.addSubview(stack)
        stack.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor,
                     paddingLeft: 16, paddingBottom: 12)
        
        collectionView.addSubview(mapButton)
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
        collectionView.contentInsetAdjustmentBehavior = .never
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
        return CGSize(width: view.frame.width, height: 120)
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

////MARK: - AuthenticationDelegate
//
//extension ConversationsController: AuthenticationDelegate {
//    func authenticationComplete() {
//        dismiss(animated: true, completion: nil)
//        configureUI()
//        fetchConversations()
//    }
//}

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
