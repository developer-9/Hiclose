//
//  VideoController.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/06/22.
//

import UIKit
import AgoraRtcKit
import Firebase

protocol VideoControllerDelegate: AnyObject {
    func deleteCallingIndicator()
}

class VideoController: UIViewController {
    
    //MARK: - Properties
    
    var user: User? {
        didSet { populateUserData() }
    }
    
    weak var delegate: VideoControllerDelegate?
    var agoraKit: AgoraRtcEngineKit?
    private var localVideo: AgoraRtcVideoCanvas?
    private var remoteVideo: AgoraRtcVideoCanvas?
        
    var isRemoteVideoRender: Bool = true {
        didSet {
            if let it = localVideo, let view = it.view {
                if view.superview == localView {
                    remoteView.isHidden = !isRemoteVideoRender
                } else if view.superview == remoteView {
                    localView.isHidden = isRemoteVideoRender
                }
            }
        }
    }
    
    var isLocalVideoRender: Bool = false {
        didSet {
            if let it = localVideo, let view = it.view {
                if view.superview == localView {
                    localView.isHidden = isLocalVideoRender
                } else if view.superview == remoteView {
                    remoteView.isHidden = isLocalVideoRender
                }
            }
        }
    }
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .backgroundColor
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var callingPulsateView: CallingPulsateView = {
        let frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        let cp = CallingPulsateView(frame: frame)
        
        cp.addSubview(profileImageView)
        profileImageView.setDimensions(height: 198, width: 198)
        profileImageView.layer.cornerRadius = 198 / 2
        profileImageView.centerX(inView: cp)
        profileImageView.centerY(inView: cp, constant: 36)
        return cp
    }()
    
    private lazy var remoteView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundColor
        
        view.addSubview(callingPulsateView)
        callingPulsateView.setDimensions(height: 300, width: 300)
        callingPulsateView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 52)
        callingPulsateView.centerX(inView: view)
        return view
    }()
    
    private lazy var localView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundColor
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 4
        view.layer.borderColor = UIColor.white.cgColor
        view.setDimensions(height: 200, width: 120)
        
        let label = UILabel()
        label.text = "🔥"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 50)
        view.addSubview(label)
        label.centerX(inView: view)
        label.centerY(inView: view)
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var micButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "mic.fill")?.withRenderingMode(.alwaysTemplate),
                        for: .normal)
        button.tintColor = .white
        button.backgroundColor = .darkGray
        button.setDimensions(height: 62, width: 62)
        button.layer.cornerRadius = 62 / 2
        button.clipsToBounds = true
        button.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(handleMic), for: .touchUpInside)
        return button
    }()
 
    private lazy var videoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "video.fill")?.withRenderingMode(.alwaysTemplate),
                        for: .normal)
        button.tintColor = .white
        button.backgroundColor = .darkGray
        button.setDimensions(height: 62, width: 62)
        button.layer.cornerRadius = 62 / 2
        button.clipsToBounds = true
        button.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(handleVideo), for: .touchUpInside)
        return button
    }()
    
    private lazy var leaveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "phone.down.fill")?.withRenderingMode(.alwaysTemplate),
                        for: .normal)
        button.tintColor = .white
        button.backgroundColor = .red
        button.setDimensions(height: 62, width: 62)
        button.layer.cornerRadius = 62 / 2
        button.clipsToBounds = true
        button.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(handlelHangUp), for: .touchUpInside)
        return button
    }()
    
    private lazy var cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.fill")?.withRenderingMode(.alwaysTemplate),
                        for: .normal)
        button.tintColor = .white
        button.backgroundColor = .darkGray
        button.setDimensions(height: 42, width: 42)
        button.layer.cornerRadius = 42 / 2
        button.clipsToBounds = true
        button.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(handleCamera), for: .touchUpInside)
        return button
    }()
    
    private let gradientLayer = CAGradientLayer()
    
    //MARK: - Lifecycle
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AppID, delegate: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        self.perform(#selector(animatePulsating), with: nil, afterDelay: 0.3)
        setupVideo()
        setupLocalVideo()
        joinChannel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 140)
    }
    
    //MARK: - Actions
    
    @objc func animatePulsating() {
        callingPulsateView.animatePulsatingLayer()
    }
    
    @objc func handleCamera(_ sender: UIButton) {
        sender.isSelected.toggle()
        sender.backgroundColor = sender.isSelected ? .white : .darkGray
        agoraKit?.switchCamera()
    }
    
    @objc func handleMic(_ sender: UIButton) {
        sender.isSelected.toggle()
        sender.backgroundColor = sender.isSelected ? .white : .darkGray
        agoraKit?.muteLocalAudioStream(sender.isSelected)
    }
    
    @objc func handleVideo(_ sender: UIButton) {
        sender.isSelected.toggle()
        sender.backgroundColor = sender.isSelected ? .white : .darkGray
        agoraKit?.enableLocalVideo(!sender.isSelected)
    }
    
    @objc func handlelHangUp() {
        leaveChannel()
        dismiss(animated: true, completion: nil)
        delegate?.deleteCallingIndicator()
    }
    
    //MARK: - Helpers
    
     private func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(remoteView)
        remoteView.fillSuperview()
        
        configureGradientLayerView()
        
        view.addSubview(nameLabel)
        nameLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                         paddingTop: 28, paddingLeft: 24)
        
        let stack = UIStackView(arrangedSubviews: [micButton, leaveButton, videoButton])
        stack.axis = .horizontal
        stack.spacing = 32
        view.addSubview(stack)
        stack.centerX(inView: view)
        stack.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 12)
        
        view.addSubview(localView)
        localView.anchor(bottom: stack.topAnchor, right: view.rightAnchor,
                         paddingBottom: 24, paddingRight: 18)
        
        view.addSubview(cameraButton)
        cameraButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor,
                            paddingTop: 16, paddingRight: 32)
    }
    
    private func configureGradientLayerView() {
        gradientLayer.colors = [UIColor.backgroundColor.cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0, 1]
        view.layer.addSublayer(gradientLayer)
    }
    
    private func populateUserData() {
        guard let user = user else { return }
        guard let url = URL(string: user.profileImageUrl) else { return }
        nameLabel.text = user.fullname
        profileImageView.sd_setImage(with: url, completed: nil)
    }
    
    private func setupVideo() {
        agoraKit?.enableVideo()
        agoraKit?.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(size: AgoraVideoDimension640x360, frameRate: .fps60, bitrate: AgoraVideoBitrateStandard, orientationMode: .adaptative))
    }
    
    private func setupLocalVideo() {
        let localVideo = AgoraRtcVideoCanvas()
        localVideo.uid = 0
        localVideo.view = localView
        localVideo.renderMode = .hidden
        agoraKit?.setupLocalVideo(localVideo)
    }
    
    private func joinChannel() {
        agoraKit?.joinChannel(byToken: Token, channelId: "Hiclose", info: nil, uid: 0, joinSuccess: { channel, uid, elapsed in
            self.isLocalVideoRender = true
        })
    }
    
    private func leaveChannel() {
        agoraKit?.leaveChannel(nil)
        isRemoteVideoRender = false
        isLocalVideoRender = false
        localView.isHidden = true
        remoteView.isHidden = true
    }
}

//MARK: - AgoraRtcEngineDelegate

extension VideoController: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid: UInt, size: CGSize, elapsed: Int) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = remoteView
        videoCanvas.renderMode = .hidden
        
        agoraKit?.setupRemoteVideo(videoCanvas)
    }
}
