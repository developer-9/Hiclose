//
//  NewMessageController.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/02/05.
//

import UIKit
import PanModal

private let reuseIdentifier = "UserCell"
private let headerIdentifier = "HeaderView"

protocol NewMessageControllerDelegate: AnyObject {
    func controller(wantsToStartChatFromNewMessageController user: User)
}

class NewMessageController: UICollectionViewController {
    
    //MARK: - Properties
    
    private var users = [User]() {
        didSet { collectionView.reloadData() }
    }
    weak var delegate: NewMessageControllerDelegate?
    private let headerView = NewMessageHeader()
    private var isShortFormEnabled = true
    
    private var ifNoFriendLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No friends yet😵‍💫"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private var ifNoFriendLabel2: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "友達を検索してリクエストを送ろう！"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchFriends()
        friendsAreExist()
    }
    
    //MARK: - API
    
    private func fetchFriends() {
        FriendService.fetchMyFriends { friends in
            self.users = friends
        }
    }
    
    private func friendsAreExist() {
        FriendService.friendsAreExist { bool in
            self.ifNoFriendLabel.isHidden = !bool
            self.ifNoFriendLabel2.isHidden = !bool
        }
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        collectionView.backgroundColor = .backgroundColor
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(NewMessageHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        let stack = UIStackView(arrangedSubviews: [ifNoFriendLabel, ifNoFriendLabel2])
        stack.axis = .vertical
        stack.spacing = 4
        
        collectionView.addSubview(stack)
        stack.centerX(inView: collectionView)
        stack.anchor(top: collectionView.topAnchor, paddingTop: 150)
    }
}

//MARK: - UICollectionViewDataSource

extension NewMessageController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserCell
        cell.viewModel = UserCellViewModel(user: users[indexPath.row])
        return cell
    }
}

//MARK: - UICollectionViewDelegate

extension NewMessageController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        delegate?.controller(wantsToStartChatFromNewMessageController: user)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! NewMessageHeader
        return header
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension NewMessageController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2)  / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
}

//MARK: - PanModalPresentable

extension NewMessageController: PanModalPresentable {
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
