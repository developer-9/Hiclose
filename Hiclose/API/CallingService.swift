//
//  CallingService.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/07/08.
//

import Firebase


struct CallingService {
    static func uploadCallingIndicator(toUid uid: String, completion: ((Error?) -> Void)?) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        UserService.fetchUser(withUid: currentUid) { user in
            let docRef = COLLECTION_CALLING.document(uid).collection("user-calling").document()
            let data: [String: Any] = ["timestamp": Timestamp(date: Date()),
                                       "id": docRef.documentID,
                                       "fromUid": user.uid,
                                       "profileImageUrl": user.profileImageUrl,
                                       "fullname": user.fullname]
            docRef.setData(data, completion: completion)
        }
    }
    
    static func fetchCallingIndicator(completion: @escaping(Calling) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_CALLING.document(currentUid).collection("user-calling").addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            snapshot.documentChanges.forEach { change in
                if change.type == .added {
                    let dictionary = change.document.data()
                    let calling = Calling(dictionary: dictionary)
                    completion(calling)
                }
            }
        }
    }
    
    static func deleteCallingIndicator(withId id: String, uid: String, completion: ((Error?) -> Void)?) {
        COLLECTION_CALLING.document(uid).collection("user-calling").document(id)
            .delete(completion: completion)
    }
}
