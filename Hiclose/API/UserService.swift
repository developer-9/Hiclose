//
//  UserService.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/02/07.
//

import Firebase

struct UserService {
    static func fetchUsers(completion: @escaping([User]) -> Void) {
        COLLECTION_USERS.getDocuments { (snapshot, error) in
            guard var users = snapshot?.documents.map({ User(dictionary: $0.data()) }) else { return }
            
            if let i = users.firstIndex(where: { $0.uid == Auth.auth().currentUser?.uid }) {
                users.remove(at: i)
            }
            
            completion(users)
         }
    }
    
    static func fetchUser(withUid uid: String, completion: @escaping(User) -> Void) {
        COLLECTION_USERS.document(uid).getDocument { (snapshot, error) in
            guard let dictionary = snapshot?.data() else { return }
            let user = User(dictionary: dictionary)
            completion(user)
        }
    }
    
    static func fetchdummyAccounts(completion: @escaping([User]) -> Void) {
        var users = [User]()
        let uids: [String] = ["fDcpHOW64PgCkiQXXngkw6fT6Qm1", "hT03j7n7FJaZLtLYw3DeZGzqJhF2",
                              "5u6owk0ZcKPa8XWPzWka51ibyNC3"]
        uids.forEach { uid in
            COLLECTION_USERS.document(uid).getDocument { snapshot, error in
                guard let dictionary = snapshot?.data() else { return }
                let user = User(dictionary: dictionary)
                users.append(user)
                completion(users)
            }
        }
    }
    
    static func guestOrNot(completion: @escaping(Bool?) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let uids: [String] = ["fDcpHOW64PgCkiQXXngkw6fT6Qm1", "hT03j7n7FJaZLtLYw3DeZGzqJhF2",
                              "5u6owk0ZcKPa8XWPzWka51ibyNC3"]
        let bool = uids.contains(where: { $0 == currentUid })
        completion(bool)
    }
}
