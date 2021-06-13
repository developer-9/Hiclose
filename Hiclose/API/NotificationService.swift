//
//  NotificationService.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/05/29.
//

import Firebase

struct NotificationService {
    static func uploadNotification(toUid uid: String, fromUser: User, type: NotificationType,
                                   completion: ((Error?) -> Void)?) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard uid != currentUid else { return }
        
        let docRef = COLLECTION_NOTIFICATIONS.document(uid).collection("user-notifications").document()
        let data: [String: Any] = ["timestamp": Timestamp(date: Date()),
                                   "uid": fromUser.uid,
                                   "type": type.rawValue,
                                   "id": docRef.documentID,
                                   "profileImageUrl": fromUser.profileImageUrl,
                                   "fullname": fromUser.fullname]
        docRef.setData(data, completion: completion)
    }
    
    static func fetchNotifications(completion: @escaping([Notification]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let query = COLLECTION_NOTIFICATIONS.document(currentUid).collection("user-notifications")
            .order(by: "timestamp", descending: true)
        
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            let notifications = documents.map({ Notification(dictionary: $0.data()) })
            completion(notifications)
        }
    }
    
    static func notificationsAreExist(completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_NOTIFICATIONS.document(currentUid).collection("user-notifications").getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            let isEmpty = snapshot.isEmpty
            completion(isEmpty)
        }
    }
    
    static func deleteNotification(withNotifId id: String, completion: ((Error?) -> Void)?) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_NOTIFICATIONS.document(currentUid).collection("user-notifications").document(id)
            .delete(completion: completion)
    }
}
