//
//  Constants.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/02/02.
//

import Firebase

let COLLECTION_USERS = Firestore.firestore().collection("users")
let COLLECTION_MESSAGES = Firestore.firestore().collection("messages")
let COLLECTION_STATUS = Firestore.firestore().collection("status")
let COLLECTION_REQUEST = Firestore.firestore().collection("friendRequest")
let COLLECTION_LIST = Firestore.firestore().collection("friendList")
let COLLECTION_NOTIFICATIONS = Firestore.firestore().collection("notifications")
let DB_REF = Database.database().reference()
let REF_LOCATIONS = DB_REF.child("locations")
