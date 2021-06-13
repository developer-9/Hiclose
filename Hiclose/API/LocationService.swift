//
//  LocationService.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/06/04.
//

import Firebase
import GeoFire

struct LocationService {
    static let location = LocationHandler.shared.locationManager.location
    
    static func fetchFriendsLocation(location: CLLocation, completion: @escaping(User) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let geofire = GeoFire(firebaseRef: REF_LOCATIONS.child(currentUid))
        
        REF_LOCATIONS.child(currentUid).observe(.value) { (snapshot) in
            geofire.query(at: location, withRadius: 50).observe(.keyEntered, with: { (uid, location) in
                UserService.fetchUser(withUid: uid) { user in
                    var user = user
                    user.location = location
                    completion(user)
                }
            })
        }
    }
    
    static func setToFriendsWithMyLocation(completion: @escaping(Error) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        setLocation(uid: currentUid) { _ in
            FriendService.fetchFriends { friends in
                for friend in friends {
                    setLocation(uid: friend.uid) { _ in
                        print("DEBUG: COMPLETE SETLOCATION")
                    }
                }
            }
        }
    }
    
    private static func setLocation(uid: String, completion: @escaping GFCompletionBlock) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let geofire = GeoFire(firebaseRef: REF_LOCATIONS.child(uid))
        guard let location = self.location else { return }
        geofire.setLocation(location, forKey: currentUid, withCompletionBlock: completion)
    }
}
