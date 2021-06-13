//
//  CustomInputAccessoryView.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/02/08.
//

import UIKit
import AVFoundation

protocol CustomInputAccessoryViewDelegate: class {
    func inputView(_ inputView: CustomInputAccessoryView, wantsToSend message: String)
    func presentImagePickerController()
}

class CustomInputAccessoryView: UIView {
    
    //MARK: - Properties
    
    private var audioPlayer: AVAudioPlayer!
        
    weak var delegate: CustomInputAccessoryViewDelegate?
    
    private lazy var messageInputTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.isScrollEnabled = false
        tv.keyboardAppearance = .dark
        tv.backgroundColor = .darkGray
        tv.textColor = .white
        return tv
    }()
    
    private let photoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        button.backgroundColor = .backgroundColor
        button.tintColor = .lightGray
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        return button
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        button.backgroundColor = .backgroundColor
        button.tintColor = .systemPurple
        button.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Aa"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    //MARK: - Actions
    
    @objc func handleSelectPhoto() {
        delegate?.presentImagePickerController()
    }
    
    @objc func handleSendMessage() {
        guard let message = messageInputTextView.text else { return }
        delegate?.inputView(self, wantsToSend: message)
        clearMessageText()
        playSound(name: "send")
    }
    
    @objc func handleTextInputChange() {
        placeholderLabel.isHidden = !self.messageInputTextView.text.isEmpty
        sendButton.isEnabled = !self.messageInputTextView.text.isEmpty
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        autoresizingMask = .flexibleHeight
        backgroundColor = .backgroundColor
        
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 10
        layer.shadowOffset = .init(width: 0, height: -1)
        layer.shadowColor = UIColor.lightGray.cgColor
        
        addSubview(photoButton)
        photoButton.anchor(left: leftAnchor, paddingLeft: 12)
        
        addSubview(sendButton)
        sendButton.anchor(top: topAnchor, right: rightAnchor, paddingTop: 8, paddingRight: 16)
        sendButton.setDimensions(height: 40, width: 40)
        
        addSubview(messageInputTextView)
        messageInputTextView.anchor(top: topAnchor, left: photoButton.rightAnchor,
                                    bottom: safeAreaLayoutGuide.bottomAnchor,
                                    right: sendButton.leftAnchor,
                                    paddingTop: 12, paddingLeft: 16, paddingBottom: 8, paddingRight: 6)
        messageInputTextView.layer.cornerRadius = 16
        
        photoButton.centerY(inView: messageInputTextView)
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(left: messageInputTextView.leftAnchor, paddingLeft: 6)
        placeholderLabel.centerY(inView: messageInputTextView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextInputChange),
                                               name: UITextView.textDidChangeNotification, object: nil)
    }
    
    private func clearMessageText() {
        messageInputTextView.text = nil
        placeholderLabel.isHidden = false
        sendButton.isEnabled = false
    }
}

//MARK: - AVAudioPlayerDelegate

extension CustomInputAccessoryView: AVAudioPlayerDelegate {
    func playSound(name: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: "mp3") else {
            print("DEBUG: SOUND SOURCE FILE NOT FOUND")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer.delegate = self
            audioPlayer.play()
        } catch {
            print("DEBUG: COULDNT PLAY AUDIO")
        }
    }
}
