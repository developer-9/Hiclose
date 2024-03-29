//
//  NowCollectionView.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/07/02.
//

import UIKit
import Firebase

private let reuseIdentifier = "NowCell"

protocol  NowCollectionViewDelegate: AnyObject {
    func presentGuestAlert()
}

class NowCollectionView: UICollectionView {
    
    //MARK: - Properties
    
    private var friends = [User]()
    
    private var boredNowBool = Bool() {
        didSet { populateBoredNowView() }
    }
    
    weak var nowDelegate: NowCollectionViewDelegate?
    private var guestBool: Bool!
    
    private lazy var boredNowPulsateView: BoredNowPulsateView = {
        let frame = CGRect(x: 0, y: 0, width: 72, height: 72)
        let cp = BoredNowPulsateView(frame: frame)
        
        cp.addSubview(boredNowView)
        boredNowView.centerX(inView: cp)
        boredNowView.centerY(inView: cp)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleBoredNow))
        cp.addGestureRecognizer(tap)
        
        return cp
    }()
    
    private lazy var boredNowView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.setDimensions(height: 60, width: 60)
        view.layer.cornerRadius = 60 / 2

        view.addSubview(boredNowLabel)
        boredNowLabel.centerY(inView: view)
        boredNowLabel.centerX(inView: view)

        return view
    }()
    
    private let boredNowLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap Me!"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12.5, weight: .heavy)
        label.numberOfLines = 0
        label.setDimensions(height: 50, width: 50)
        return label
    }()
        
    //MARK: - Lifecycle
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        configureCollectionView()
        fetchBoredNowFromMyFriends()
        checkMyBoredNowBool()
        guestOrNot()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - API
    
    func guestOrNot() {
        UserService.guestOrNot { bool in
            self.guestBool = bool
        }
    }
    
    func fetchBoredNowFromMyFriends() {
        BoredNowService.fetchBoredNowFromMyFriends { friends in
            self.friends = friends
            self.reloadData()
        }
    }
    
    func checkMyBoredNowBool() {
        checkMyBoredNowBool { boredNow in
            self.boredNowBool = boredNow.boredNow
            self.reloadData()
        }
    }
    
    private func updateBoredNowToFriends() {
        BoredNowService.updateBoredNowToFriends(boredNow: boredNowBool) { _ in
            self.reloadData()
        }
    }
    
    private func updateMyBoredNowBool() {
        BoredNowService.updateMyBoredNowBool(withBool: boredNowBool) { _ in
        }
    }
    
    private func checkMyBoredNowBool(completion: @escaping(BoredNow) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_BOREDNOW.document(currentUid).getDocument { snapshot, error in
            if let snapshot = snapshot, snapshot.exists {
                guard let dictionary = snapshot.data() else { return }
                let boredNow = BoredNow(dictionary: dictionary)
                completion(boredNow)
            } else {
                self.boredNowLabel.text = "Tap Me!"
                self.boredNowView.backgroundColor = .black
            }
        }
    }
    
    //MARK: - Ations
    
    @objc func animatePulsating() {
        boredNowPulsateView.animatePulsatingLayer()
    }
    
    @objc func handleBoredNow(_ sender: UITapGestureRecognizer) {
        if self.guestBool {
            nowDelegate?.presentGuestAlert()
        } else {
            if sender.state == .ended {
                boredNowBool.toggle()
            }
            updateMyBoredNowBool()
            updateBoredNowToFriends()
            self.perform(#selector(animatePulsating), with: nil, afterDelay: 0.5)
        }
    }
        
    //MARK: - Helpers
    
    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionViewLayout = layout
        showsHorizontalScrollIndicator = false
        contentInsetAdjustmentBehavior = .never
        delegate = self
        dataSource = self
        backgroundColor = .backgroundColor
        register(NowCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        addSubview(boredNowPulsateView)
        boredNowPulsateView.setDimensions(height: 72, width: 72)
        boredNowPulsateView.centerY(inView: self)
        boredNowPulsateView.anchor(left: leftAnchor, paddingLeft: 10)
    }
    
    private func populateBoredNowView() {
        if boredNowBool {
            boredNowLabel.text = "Bored Now"
            boredNowView.backgroundColor = UIColor.gradientColor(size: CGSize(width: 60, height: 60),
                                                                 colors: [.systemPurple, .blue])
            boredNowView.layer.borderColor = UIColor.black.cgColor
            boredNowView.layer.borderWidth = 1
        } else {
            boredNowLabel.text = "Busy Now"
            boredNowLabel.textColor = .white
            boredNowView.backgroundColor = UIColor.gradientColor(size: CGSize(width: 60, height: 60),
                                                                 colors: [.darkGray, .backgroundColor])
            boredNowView.layer.borderColor = UIColor.white.cgColor
            boredNowView.layer.borderWidth = 1.25
        }
    }
}

//MARK: - UICollectionViewDataSource

extension NowCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NowCell
        cell.viewModel = UserCellViewModel(user: friends[indexPath.row])
        return cell
    }
}

//MARK: - UICollectionViewDelegate

extension NowCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension NowCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 88, bottom: 0, right: 0)
    }
}
