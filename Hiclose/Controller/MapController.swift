//
//  MapController.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/06/03.
//

import UIKit
import MapKit
import GeoFire
import Firebase

private let annotationIdentifier = "FriendAnnotation"

class MapController: UIViewController {
    
    //MARK: - Properties
    
    private var location = LocationHandler.shared.locationManager.location
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    
    private let gradientLayer = CAGradientLayer()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Hiclose Map🔥"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    private let zoomToMyLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "scope"), for: .normal)
        button.tintColor = . white
        button.backgroundColor = .backgroundColor
        button.addTarget(self, action: #selector(zoomToMyLocation), for: .touchUpInside)
        return button
    }()
        
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        enableLocationServices()
        fetchFriendsLocation()
    }
    
    override func viewDidLayoutSubviews() {
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 180)
    }
        
    //MARK: - API
        
    private func fetchFriendsLocation() {
        guard let location = locationManager.location else { return }
        LocationService.fetchFriendsLocation(location: location) { friend in
            print("DEBUG: FRIEND NAME IS \(friend.fullname), COORDINATE IS \(friend.location?.coordinate)")
            guard let coordinate = friend.location?.coordinate else { return }
            let annotation = FriendAnnotation(uid: friend.uid, coordinate: coordinate,
                                              profileImageUrl: friend.profileImageUrl)
            
            var friendIsVisible: Bool {
                return self.mapView.annotations.contains { annotation -> Bool in
                    guard let friendAnno = annotation as? FriendAnnotation else { return false }
                    if friendAnno.uid == friend.uid {
                        print("DEBUG: HANDLE UPDATE FRIEND POSITION")
                        friendAnno.updateAnnotationPosition(withCoordinate: coordinate)
                        return true
                    }
                    return false
                }
            }
            
            if !friendIsVisible {
                print("DEBUG: ANNOTATION IS \(annotation.uid)")
                guard let currentUid = Auth.auth().currentUser?.uid else { return }
                if annotation.uid != currentUid {
                    self.mapView.addAnnotation(annotation)
                    self.perform(#selector(self.zoomToFit), with: nil, afterDelay: 0.5)
                }
            }
        }
    }
    
    //MARK: - Actions
    
    @objc func zoomToMyLocation() {
        self.mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    @objc func zoomToFit() {
        self.mapView.zoomToFit(annotations: self.mapView.annotations)
        print("DEBUG: COMPLETE ZOOM TO ANNOTATION \(mapView.annotations)")
    }
    
    @objc func handleDismiss() {
        navigationController?.popViewController(animated: true)
    }
        
    //MARK: - Helpers
    
    private func configureUI() {
        configureMapView()
        configureGradientLayerView()
        
        view.addSubview(titleLabel)
        titleLabel.centerX(inView: view)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 20)
        
        view.addSubview(backButton)
        backButton.centerY(inView: titleLabel)
        backButton.anchor(left: view.leftAnchor, paddingLeft: 24)
        
        view.addSubview(zoomToMyLocationButton)
        zoomToMyLocationButton.layer.shadowColor = UIColor.backgroundColor.cgColor
        zoomToMyLocationButton.layer.shadowRadius = 2
        zoomToMyLocationButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        zoomToMyLocationButton.layer.shadowOpacity = 0.6
        zoomToMyLocationButton.setDimensions(height: 60, width: 60)
        zoomToMyLocationButton.layer.cornerRadius = 60 / 2
        zoomToMyLocationButton.centerX(inView: view)
        zoomToMyLocationButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 32)
    }
    
    private func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
        
        LocationService.setToFriendsWithMyLocation { _ in
        }
    }
    
    private func configureGradientLayerView() {
        gradientLayer.colors = [UIColor.backgroundColor.cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0, 1]
        view.layer.addSublayer(gradientLayer)
    }
}

//MARK: - MKMapViewDelegate

extension MapController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? FriendAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            view.image = #imageLiteral(resourceName: "fire")
            view.backgroundColor = .backgroundColor
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFill
            view.setDimensions(height: 52, width: 52)
            view.layer.cornerRadius = 52 / 2
            return view
        }
        return nil
    }
}

//MARK: - CLLocationManagerDelegate

extension MapController: CLLocationManagerDelegate {
    func enableLocationServices() {
        locationManager.delegate = self
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("DEBUG: Not determined..")
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("DEBUG: Auth always..")
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: Auth when in use..")
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
}

//MARK: - MKMapView

extension MKMapView {
    func zoomToFit(annotations: [MKAnnotation]) {
        var zoomRect = MKMapRect.null
        
        annotations.forEach { (annotation) in
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y,
                                      width: 0.01, height: 0.01)
            zoomRect = zoomRect.union(pointRect)
        }
        
        let insets = UIEdgeInsets(top: 80, left: 80, bottom: 200, right: 80)
        UIView.animate(withDuration: 2) {
            self.setVisibleMapRect(zoomRect, edgePadding: insets, animated: true)
        }
    }
}
