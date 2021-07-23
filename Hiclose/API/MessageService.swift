//
//  MessageService.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/02/11.
//

import Firebase

struct MessageService {
    static func fetchMessages(forUser user: User, completion: @escaping([Message]) -> Void) {
        var messages = [Message]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let query = COLLECTION_MESSAGES.document(currentUid).collection(user.uid).order(by: "timestamp")
        
        query.addSnapshotListener { (snapshot, error) in
            snapshot?.documentChanges.forEach({ change in
                if change.type == .added {
                    let dictionary = change.document.data()
                    messages.append(Message(dictionary: dictionary))
                    completion(messages)
                }
            })
        }
    }
    
    static func uploadMessage(_ message: String? = nil, imagesUrl: [String]? = nil, to user: User,
                              completion: @escaping(Error?) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        var data = [String: Any]()
        
        if let message = message {
            data = ["text": message,
                    "fromId": currentUid,
                    "toId": user.uid,
                    "timestamp": Timestamp(date: Date())]
        }
        
        if let imagesUrl = imagesUrl {
            data = ["imagesUrl": imagesUrl,
                    "fromId": currentUid,
                    "toId": user.uid,
                    "timestamp": Timestamp(date: Date())]
        }
        
        COLLECTION_MESSAGES.document(currentUid).collection(user.uid).addDocument(data: data) { _ in
            COLLECTION_MESSAGES.document(user.uid).collection(currentUid).addDocument(data: data, completion: completion)
            
            COLLECTION_MESSAGES.document(currentUid).collection("recent-messages").document(user.uid).setData(data)
            COLLECTION_MESSAGES.document(user.uid).collection("recent-messages").document(currentUid).setData(data)
        }
    }
    
    static func uploadMessageFromHicloseAccount(completion: @escaping(Error?) -> Void) {
        UserService.fetchUser(withUid: "zfpbiUaLKtTSaUs86q2WHxBjD8r1") { hicloseAccount in
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            let data: [String: Any] = ["text": "Welcome to Hiclose🔥",
                                       "fromId": hicloseAccount.uid,
                                       "toId": currentUid,
                                       "timestamp": Timestamp(date: Date())]
            COLLECTION_MESSAGES.document(currentUid).collection(hicloseAccount.uid).addDocument(data: data) { _ in
                COLLECTION_MESSAGES.document(hicloseAccount.uid).collection(currentUid).addDocument(data: data) { _ in
                    COLLECTION_MESSAGES.document(currentUid).collection("recent-messages").document(hicloseAccount.uid).setData(data) { _ in
                        COLLECTION_MESSAGES.document(hicloseAccount.uid).collection("recent-messages").document(currentUid).setData(data, completion: completion)
                    }
                }
            }
        }
    }
        
    static func fetchConversationsWithFirstMessage(completion: @escaping([Conversation]) -> Void) {
        var conversations = [Conversation]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let query = COLLECTION_MESSAGES.document(currentUid).collection("recent-messages")
            .order(by: "timestamp")
        query.addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            if snapshot.isEmpty {
                uploadMessageFromHicloseAccount { _ in
                }
            }
            snapshot.documentChanges.forEach { change in
                let dictionary = change.document.data()
                let message = Message(dictionary: dictionary)
                
                UserService.fetchUser(withUid: message.chatPartnerId) { user in
                    let conversation = Conversation(user: user, message: message)
                    conversations.append(conversation)
                    completion(conversations)
                }
            }
        }
    }
    
    static func fetchConversations(completion: @escaping([Conversation]) -> Void) {
        var conversations = [Conversation]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let query = COLLECTION_MESSAGES.document(currentUid).collection("recent-messages").order(by: "timestamp")
        query.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            snapshot.documentChanges.forEach { change in
                let dictionary = change.document.data()
                let message = Message(dictionary: dictionary)
                
                UserService.fetchUser(withUid: message.chatPartnerId) { user in
                    let conversation = Conversation(user: user, message: message)
                    conversations.append(conversation)
                }
            }
        }
    }
}
