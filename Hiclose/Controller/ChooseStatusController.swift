//
//  ChooseStatusController.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/04/27.
//

import UIKit
import PanModal

private let reuseIdentifier = "EmojiCell"

protocol ChooseStatusControllerDelegate: AnyObject {
    func didSelect(option: Emoji)
}

class ChooseStatusController: UICollectionViewController {
    
    //MARK: - Properties
    
    weak var delegate: ChooseStatusControllerDelegate?
    private var isShortFormEnabled = true
        
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
        
    //MARK: - Helpers
    
    private func configureUI() {
        collectionView.backgroundColor = .backgroundColor
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
}

//MARK: - UICollectionViewDataSource

extension ChooseStatusController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Emoji.allCases.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! EmojiCell
        guard let option = Emoji(rawValue: indexPath.row) else { return cell }
        cell.emojiLabel.text = option.description
        return cell
    }
}

//MARK: - UICollectionViewDelegate

extension ChooseStatusController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let option = Emoji(rawValue: indexPath.row) else { return }
        delegate?.didSelect(option: option)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension ChooseStatusController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2)  / 8
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 30)
    }
}

//MARK: - PanModalPresentable

extension ChooseStatusController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }

    var shortFormHeight: PanModalHeight {
        return isShortFormEnabled ? .contentHeight(440.0) : longFormHeight
    }

    var anchorModalToLongForm: Bool {
        return false
    }

    func willTransition(to state: PanModalPresentationController.PresentationState) {
        guard isShortFormEnabled, case .longForm = state
            else { return }

        isShortFormEnabled = false
        panModalSetNeedsLayoutUpdate()
    }
}

