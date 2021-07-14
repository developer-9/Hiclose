//
//  FriendService.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/05/31.
//

import Firebase

struct FriendService {
    static func friendRequest(withUid uid: String, completion: @escaping(Error?) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_REQUEST.document(currentUid).collection("friend-request").document(uid).setData([:], completion: completion)
    }
    
    static func deleteFriendRequest(withUid uid: String, completion: @escaping(Error?) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard uid != currentUid else { return }
        
        COLLECTION_REQUEST.document(uid).collection("friend-request").document(currentUid).delete(completion: completion)
    }
    
    static func friendAccept(withUid uid: String, completion: @escaping(Error?) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        UserService.fetchUser(withUid: uid) { friend in
            let data: [String: Any] = ["boredNow": false]
            COLLECTION_LIST.document(currentUid).collection("friend-list").document(uid).setData(data) { _ in
                COLLECTION_LIST.document(uid).collection("friend-list").document(currentUid).setData(data, completion: completion)
            }
        }
    }
        
    static func checkIfUserIsRequested(uid: String, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_REQUEST.document(currentUid).collection("friend-request").document(uid).getDocument { (snapshot, error) in
            guard let isRequested = snapshot?.exists else { return }
            completion(isRequested)
        }
    }
    
    static func fetchMyFriends(completion: @escaping([User]) -> Void) {
        var users = [User]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_LIST.document(currentUid).collection("friend-list").getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            for document in snapshot.documents {
                let uid = document.documentID
                UserService.fetchUser(withUid: uid) { user in
                    users.append(user)
                    completion(users)
                }
            }
        }
    }
    
    static func friendsAreExist(completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_LIST.document(currentUid).collection("friend-list").getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            let isEmpty = snapshot.isEmpty
            completion(isEmpty)
        }
    }
    
    static func fetchFrineds(withUid uid: String, completion: @escaping([User]) -> Void) {
        var users = [User]()
        COLLECTION_LIST.document(uid).collection("friend-list").getDocuments { snapshot, error in
            guard let snapshot = snapshot else { return }
            for document in snapshot.documents {
                let uid = document.documentID
                UserService.fetchUser(withUid: uid) { user in
                    users.append(user)
                    completion(users)
                }
            }
        }
    }
}
