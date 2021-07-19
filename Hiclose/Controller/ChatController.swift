//
//  ChatController.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/02/07.
//

import UIKit
import SDWebImage
import ImagePicker
import PanModal

private let headerIdentifier = "ChatHeader"
private let reuseIdentifier = "MessageCell"

class ChatController: UICollectionViewController {
    
    //MARK: - Properties
    
    private let user: User
    private var messages = [Message]()
    private var selectedImages: [UIImage]?
    private var headerView = ChatHeader()
    
    private var guestBool: Bool! {
        didSet { customInputView.guestBool = guestBool }
    }
        
    private var layout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionHeadersPinToVisibleBounds = true
        return layout
    }()
        
    private lazy var customInputView: CustomInputAccessoryView = {
        let iv = CustomInputAccessoryView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        iv.delegate = self
        return iv
    }()
    
    //MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchMessages()
        configureNotificationObservers()
        guestOrNot()
    }
    
    override func viewDidLayoutSubviews() {
        collectionView.frame = .init(x: 0, y: 0, width: view.frame.width,
                                     height: view.frame.height - customInputView.frame.height)
    }
    
    override var inputAccessoryView: UIView? {
        get { return customInputView }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    //MARK: - API
    
    private func guestOrNot() {
        UserService.guestOrNot { bool in
            self.guestBool = bool
        }
    }
    
    private func fetchMessages() {
        MessageService.fetchMessages(forUser: user) { (messages) in
            self.messages = messages
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: [0, self.messages.count - 1], at: .bottom,
                                             animated: true)
        }
    }
    
    //MARK: - Actions
    
    @objc func keyboardWillShow() {
//        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
//        if self.view.frame.origin.y == 0 {
//            self.view.frame.origin.y -= keyboardSize - 87
//            self.headerView.frame.origin.y = 0
//        } else {
//            let suggestionHeight = self.view.frame.origin.y + keyboardSize
//            self.view.frame.origin.y -= suggestionHeight
//        }
    }
    
    @objc private func keyboardWillHide() {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    //MARK: - Helpers
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .backgroundColor
        collectionView.collectionViewLayout = layout

        navigationController?.navigationBar.isHidden = true
        
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(ChatHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.keyboardDismissMode = .interactive
        collectionView.contentInsetAdjustmentBehavior = .never
    }
    
    private func configureNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
}

//MARK: - UICollectionViewDataSource

extension ChatController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ChatHeader
        header.delegate = self
        header.viewModel = UserCellViewModel(user: user)
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
        cell.delegate = self
        cell.message = messages[indexPath.row]
        cell.message?.user = user
        return cell
    }
}

//MARK: - MessageCellDelegate

extension ChatController: MessageCellDelegate {
    func fetchCellMessages() {
        self.collectionView.reloadData()
    }
}

//MARK: - ChatHeaderDelegate

extension ChatController: ChatHeaderDelegate {
    func header(_ chatHeader: ChatHeader, showProfileWith user: User) {
        let controller = FriendProfileController(user: user)
        presentPanModal(controller)
    }
    
    func header(_ chatHeader: ChatHeader) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension ChatController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        let estimatedSizeCell = MessageCell(frame: frame)
        estimatedSizeCell.message = messages[indexPath.row]
        estimatedSizeCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = estimatedSizeCell.systemLayoutSizeFitting(targetSize)
        
        return .init(width: view.frame.width, height: estimatedSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
}

//MARK: - CustomInputAccessoryViewDelegate

extension ChatController: CustomInputAccessoryViewDelegate {
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
    
    func presentImagePickerController() {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func inputView(_ inputView: CustomInputAccessoryView, wantsToSend message: String) {
        MessageService.uploadMessage(message, to: user) { error in
            if let error = error {
                print("DEBUG: FAILED TO UPLOAD MESSAGE WITH ERROR \(error.localizedDescription)")
                return
            }
        }
    }
}

//MARK: - ImagePickerDelegate

extension ChatController: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("DEBUG: WRAPPER DID PRESS")
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.selectedImages = images
        
        ImageUploader.uploadImages(images: images) { imagesUrl in
            MessageService.uploadMessage(imagesUrl: imagesUrl, to: self.user) { error in
                if let error = error {
                    print("DEBUG: FAILED TO UPLOAD IMAGES WITH ERROR \(error.localizedDescription)")
                    return
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
