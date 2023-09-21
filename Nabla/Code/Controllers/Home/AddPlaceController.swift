//
//  AddPlaceController.swift
//  ble-tbt-navigation-ios
//
//  Created by Jaksa Tomovic on 31.08.2023..
//

import UIKit
import MapboxMaps
import MapboxGeocoder
import CoreLocation

class AddPlaceController: UIViewController, CLLocationManagerDelegate {
    
    let mapView = MapView(frame: .zero)
    let geocoder = Geocoder.shared
    
    lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.tintColor = .black
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        button.layer.masksToBounds = false
        button.layer.shadowRadius = 2.0
        button.layer.shadowOpacity = 0.5
        return button
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.backgroundColor = .yellow
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(savePlaceButtonPressed), for: .touchUpInside)
        button.clipsToBounds = true
        button.tintColor = .black
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        button.layer.masksToBounds = false
        button.layer.shadowRadius = 2.0
        button.layer.shadowOpacity = 0.5
        return button
    }()
    
    private var originalPullUpControllerViewSize: CGSize = .zero
    
    private var locationManager: CLLocationManager!
    
    private var currentPlace: Place?
    
    var delegate: SearchViewTextFieldDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        view.addSubview(backButton)
        view.addSubview(saveButton)
        mapView.fillSuperview()
        backButton.layer.zPosition = 1000
        saveButton.layer.zPosition = 1000
        
        backButton.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: view.safeAreaInsets.top + 60, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 30)
        saveButton.anchor(view.topAnchor, left:nil, bottom: nil, right: view.rightAnchor, topConstant: view.safeAreaInsets.top + 60, leftConstant: 0, bottomConstant: 0, rightConstant: 12, widthConstant: 80, heightConstant: 30)
        
        mapView.ornaments.scaleBarView.isHidden = true
        mapView.ornaments.compassView.isHidden = true
        
        mapView.gestures.delegate = self
        
        // Show user location
        mapView.location.options.puckType = .puck2D()
 
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        addPullUpController()
        
        let markerImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        let image = UIImage(named: "map-marker")
        markerImageView.image = image
        markerImageView.center = CGPoint(x: mapView.center.x, y: mapView.center.y - 17.5)
        mapView.addSubview(markerImageView)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationManager.startUpdatingLocation()
    }
    
    public func setCurrentPlace(coordinate: CLLocationCoordinate2D) {
        reverseGeocodeCoordinate(coordinate: coordinate)
    }

    //MARK: - location delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        let userLocation :CLLocation = locations[0] as CLLocation
        let x = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        mapView.center  = mapView.mapboxMap.point(for: CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude))
   
        mapView.camera.fly(to: .init(center: x, zoom: 15), duration: 0.25, completion: nil)
        
        locationManager.stopUpdatingLocation()
        
        reverseGeocodeCoordinate(coordinate: locValue)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    private func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        let options = ReverseGeocodeOptions(coordinate: coordinate)
               
        geocoder.geocode(options) { (placemarks, attribution, error) in
            guard let placemark = placemarks?.first else {
                return
            }
            print(placemark.formattedName)
            print(placemark.postalAddress ?? "")
            print(placemark.country ?? "")
            print(placemark.address ?? "")
            print(placemark.name )
            print(placemark.imageName ?? "")
            print(placemark.genres?.joined(separator: ", ") ?? "")
            print(placemark.administrativeRegion?.name ?? "")
            print(placemark.administrativeRegion?.code ?? "")
            print(placemark.place?.wikidataItemIdentifier ?? "")
            
            self.currentPlace = Place(id: placemark.code ?? "", name: placemark.name, address: placemark.address ?? "", latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            self.getSearchViewControllerIfNeeded().updateTextfieldPlaceholder(text: placemark.name)

        }
    }

    private func makeSearchViewControllerIfNeeded() -> SearchViewController {
        let currentPullUpController = children
            .filter({ $0 is SearchViewController })
            .first as? SearchViewController
        let pullUpController: SearchViewController = currentPullUpController ?? SearchViewController()
        pullUpController.initialState = .contracted
        if originalPullUpControllerViewSize == .zero {
            originalPullUpControllerViewSize = pullUpController.view.bounds.size
        }

        return pullUpController
    }
    
    private func getSearchViewControllerIfNeeded() -> SearchViewController {
        let currentPullUpController = children
            .filter({ $0 is SearchViewController })
            .first as? SearchViewController
        let pullUpController: SearchViewController = currentPullUpController!
        return pullUpController
    }
    
    private func addPullUpController() {
        let pullUpController = makeSearchViewControllerIfNeeded()
        addPullUpController(pullUpController, initialStickyPointOffset: 120, animated: true)
    }
    
    func showError(_ error: Error) {
        let alertController = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func backButtonPressed() {
        self.dismissDetail()
    }
    
    @objc func savePlaceButtonPressed() {
        if currentPlace != nil {
            do {
                places.append(currentPlace!)
                let encodedData = try JSONEncoder().encode(places)
                let userDefaults = UserDefaults.standard
                userDefaults.set(encodedData, forKey: "places")
            } catch {
                // Failed to encode Contact to Data
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPlaces"), object: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension AddPlaceController: GestureManagerDelegate {
    
    public func gestureManager(_ gestureManager: GestureManager, didBegin gestureType: GestureType) {
        print("\(gestureType) didBegin")
    }
    
    public func gestureManager(_ gestureManager: GestureManager, didEnd gestureType: GestureType, willAnimate: Bool) {
        let coordinate = mapView.mapboxMap.coordinate(for: mapView.center)
        reverseGeocodeCoordinate(coordinate: coordinate)
    }
    
    public func gestureManager(_ gestureManager: GestureManager, didEndAnimatingFor gestureType: GestureType) {
        print("didEndAnimatingFor \(gestureType)")
    }
}
