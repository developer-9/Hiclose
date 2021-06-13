//
//  StatusService.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/04/28.
//

import Firebase

struct StatusService {
    static func fetchStatuses(completion: @escaping([Status]) -> Void) {
        COLLECTION_STATUS.getDocuments { (snapshot, error) in
            guard var statuses = snapshot?.documents.map({ Status(dictionary: $0.data() )}) else { return }
            
            if let i = statuses.firstIndex(where: { $0.uid == Auth.auth().currentUser?.uid }) {
                statuses.remove(at: i)
            }
            
            completion(statuses)
        }
    }
    
    static func setStatus(withStatus status: String, completion: ((Error?) -> Void)?) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let statusData = ["status": status,
                          "uid": uid] as [String: Any]
        COLLECTION_STATUS.document(uid).setData(statusData,completion: completion)
    }
    
    static func fetchStatus(withUid uid: String, completion: @escaping(Status) -> Void) {
        COLLECTION_STATUS.document(uid).getDocument { (snapshot, error) in
            guard let dictionary = snapshot?.data() else { return }
            let status = Status(dictionary: dictionary)
            completion(status)
        }
    }
}
