//
//  BoredNowService.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/07/04.
//

import Firebase

struct BoredNowService {
    static func updateBoredNowToFriends(boredNow: Bool, completion: ((Error?) -> Void)?) {
        FriendService.fetchMyFriends { myFriends in
            for myFriend in myFriends {
                FriendService.fetchFrineds(withUid: myFriend.uid) { friends in
                    for _ in friends {
                        guard let currentUid = Auth.auth().currentUser?.uid else { return }
                        let data: [String: Any] = ["boredNow": boredNow]
                        let docRef = COLLECTION_LIST.document(myFriend.uid).collection("friend-list").document(currentUid)
                        docRef.updateData(data, completion: completion)
                    }
                }
            }
        }
    }
    
    static func updateMyBoredNowBool(withBool bool: Bool, completion: ((Error?) -> Void)?) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let data: [String: Any] = ["boredNow": bool]
        COLLECTION_BOREDNOW.document(currentUid).setData(data, completion: completion)
    }
    
    static func checkMyBoredNowBool(completion: @escaping(BoredNow) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_BOREDNOW.document(currentUid).getDocument { snapshot, error in
            guard let dictionary = snapshot?.data() else { return }
            let boredNow = BoredNow(dictionary: dictionary)
            completion(boredNow)
        }
    }
    
    static func fetchBoredNowFromMyFriends(completion: @escaping([User]) -> Void) {
        var friends = [User]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let query = COLLECTION_LIST.document(currentUid).collection("friend-list").whereField("boredNow", isEqualTo: true)
        query.getDocuments { snapshot, error in
            guard let snapshot = snapshot else { return }
            for document in snapshot.documents {
                let uid = document.documentID
                UserService.fetchUser(withUid: uid) { friend in
                    friends.append(friend)
                    completion(friends)
                }
            }
        }
    }
}
