//
//  AuthService.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/02/02.
//

import UIKit
import Firebase

//MARK: - AuthCredentials

struct AuthCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
}

struct AuthService {
    static func logUserIn(withEmail email: String, password: String,
                          completion: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    static func registerUser(withCredential credentials: AuthCredentials,
                             completion: ((Error?) -> Void)?) {
        ImageUploader.uploadImage(image: credentials.profileImage) { imageUrl in
            Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { (result, error) in
                if let error = error {
                    print("DEBUG: FAILED TO REGISTRATION WITH \(error.localizedDescription)")
                    return
                }
                guard let uid = result?.user.uid else { return }
                
                let data = ["email": credentials.email,
                            "fullname": credentials.fullname,
                            "profileImageUrl": imageUrl,
                            "uid": uid,
                            "username": credentials.username] as [String: Any]
                
                COLLECTION_USERS.document(uid).setData(data, completion: completion)
            }
        }
    }
    
    static func dummyAccountLogin(withUsername username: String, completion: AuthDataResultCallback?) {
        let email = username + "@email.com"
        Auth.auth().signIn(withEmail: email, password: "password", completion: completion)
    }
}

//MARK: - EditCredentials

struct EditCredentials {
    let profileImage: UIImage
    let name: String
    let username: String
    let email: String
}

struct EditService {
    static func updateUserInfo(withCredential credentials: EditCredentials,
                               completion: @escaping(Error?) -> Void) {
        ImageUploader.uploadImage(image: credentials.profileImage) { imageUrl in
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            let updateData = ["email": credentials.email,
                              "fullname": credentials.name,
                              "profileImageUrl": imageUrl,
                              "uid": uid,
                              "username": credentials.username] as [String: Any]
            
            COLLECTION_USERS.document(uid).updateData(updateData, completion: completion)
        }
    }
}
