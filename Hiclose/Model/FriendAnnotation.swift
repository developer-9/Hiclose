//
//  FriendAnnotation.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/06/04.
//

import MapKit

class FriendAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var uid: String
    var profileImageUrl: String
    
    init(uid: String, coordinate: CLLocationCoordinate2D, profileImageUrl: String) {
        self.uid = uid
        self.coordinate = coordinate
        self.profileImageUrl = profileImageUrl
    }
    
    func updateAnnotationPosition(withCoordinate coordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.2) {
            self.coordinate = coordinate
        }
    }
}
