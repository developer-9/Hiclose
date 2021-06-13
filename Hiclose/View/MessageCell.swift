//
//  MessageCell.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/02/10.
//

import UIKit
import SDWebImage

protocol MessageCellDelegate: class {
    func fetchCellMessages()
}

class MessageCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    weak var delegate: MessageCellDelegate?
    
    var message: Message? {
        didSet { configure() }
    }
        
    private var bubbleLeftAnchor: NSLayoutConstraint!
    private var bubbleRightAnchor: NSLayoutConstraint!
    
    private var imageBubbleLeftAnchor: NSLayoutConstraint!
    private var imageBubbleRightAnchor: NSLayoutConstraint!
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.isScrollEnabled = false
        tv.isEditable = false
        tv.textColor = .white
        return tv
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var bubbleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemPurple
        return view
    }()
    
    private lazy var imageBubbleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundColor
        return view
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        addSubview(profileImageView)
        profileImageView.anchor(left: leftAnchor, bottom: bottomAnchor,
                                paddingLeft: 8, paddingBottom: -4)
        profileImageView.setDimensions(height: 32, width: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        
        addSubview(bubbleContainer)
        bubbleContainer.layer.cornerRadius = 20
        bubbleContainer.anchor(top: topAnchor, bottom: bottomAnchor)
        bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        
        bubbleLeftAnchor = bubbleContainer.leftAnchor.constraint(equalTo: profileImageView.rightAnchor,
                                                                 constant: 12)
        bubbleLeftAnchor.isActive = false
        
        bubbleRightAnchor = bubbleContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: -12)
        bubbleRightAnchor.isActive = false
        
        bubbleContainer.addSubview(textView)
        textView.centerY(inView: bubbleContainer)
        textView.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor,
                        bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor,
                        paddingTop: 4, paddingLeft: 12, paddingBottom: 4, paddingRight: 12)
    }
    
    private func configure() {
        guard let message = message else { return }
        let viewModel = MessageViewModel(message: message)
        
        bubbleContainer.backgroundColor = viewModel.messageBackgroundColor
        textView.textColor = viewModel.messageTextColor
        
        if !message.text.isEmpty {            
            textView.text = message.text
            
            bubbleLeftAnchor.isActive = viewModel.leftAnchorActive
            bubbleRightAnchor.isActive = viewModel.rightAnchorActive
        }
        
        if !message.imagesUrl.isEmpty {
            bubbleContainer.isHidden = true
            
            addSubview(imageBubbleContainer)
            imageBubbleContainer.layer.cornerRadius = 20
            imageBubbleContainer.anchor(top: topAnchor, bottom: bottomAnchor)
            imageBubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 120).isActive = true
            
            imageBubbleLeftAnchor = imageBubbleContainer.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 12)
            imageBubbleLeftAnchor.isActive = false
            
            imageBubbleRightAnchor = imageBubbleContainer.rightAnchor.constraint(equalTo: rightAnchor,
                                                                                 constant: -12)
            imageBubbleRightAnchor.isActive = false
            
            imageBubbleContainer.backgroundColor = .clear
            imageBubbleContainer.addSubview(imageView)
            imageView.centerY(inView: imageBubbleContainer)
            imageView.anchor(top: imageBubbleContainer.topAnchor)
            imageView.setDimensions(height: 120, width: 120)
            imageView.layer.cornerRadius = 20
            imageView.sd_setImage(with: viewModel.imageView, completed: nil)
            
            imageBubbleLeftAnchor.isActive = viewModel.leftAnchorActive
            imageBubbleRightAnchor.isActive = viewModel.rightAnchorActive
        }
        
        profileImageView.isHidden = viewModel.shouldHideProfileImage
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        
    }
}
