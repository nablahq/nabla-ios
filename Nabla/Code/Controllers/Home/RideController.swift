//
//  RideController.swift
//  ble-tbt-navigation-ios
//
//  Created by Jaksa Tomovic on 22.08.2023..
//
import UIKit
import MapboxMaps
import MapboxNavigation
import MapboxDirections
import MapboxCoreNavigation
import Turf
import CoreLocation
import MapboxGeocoder


class RideController: UIViewController {
    
    lazy var bottomView: UIView = {
        let view = UITableView()
        view.backgroundColor = UIColor(red: 247/255, green: 252/255, blue: 252/255, alpha: 0.9)
        view.tintColor = .black
        view.isScrollEnabled = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 30
        return view
    }()
    
    lazy var createRouteView: UIView = {
        let view = UITableView()
        view.backgroundColor = UIColor(white: 1, alpha: 1)
        view.tintColor = .black
        view.isScrollEnabled = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 3.0, height: 10.0)
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 5
        view.layer.masksToBounds = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var startLabel : UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.text = "Start 📍 Current location"
        label.tag = 0
        label.isUserInteractionEnabled = true
        label.backgroundColor = .clear
        label.textAlignment = .left
//        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(labelTapped)))
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    lazy var endLabel : UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.backgroundColor = .clear
        label.isUserInteractionEnabled = true
        label.text = "End"
        label.tag = 1
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(labelTapped)))
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    lazy var routeInfoLabel : UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    lazy var startButton: UIButton = {
        let button = UIButton()
        button.setTitle("Go", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.addTarget(self, action: #selector(startButtonPressed), for: .touchUpInside)
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 3.0, height: 10.0)
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 5
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 40
        button.clipsToBounds = true
        return button
    }()
    
    
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
    
    lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    lazy var optionsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Options", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(performAction), for: .touchUpInside)
        button.clipsToBounds = true
        button.tintColor = .black
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        button.layer.masksToBounds = false
        button.layer.shadowRadius = 2.0
        button.layer.shadowOpacity = 0.5
        return button
    }()
    
    var navigationMapView: NavigationMapView! {
        didSet {
            if let navigationMapView = oldValue {
                uninstall(navigationMapView)
            }
            if let navigationMapView = navigationMapView {
                view.addSubview(navigationMapView)
                navigationMapView.fillSuperview()
                configure(navigationMapView)
            }
        }
    }
    
    let geocoder = Geocoder.shared
    
    var waypoints: [Waypoint] = [] {
        didSet {
            waypoints.forEach {
                $0.coordinateAccuracy = -1
            }
        }
    }
    
    var currentRouteIndex: Int {
        indexedRouteResponse?.routeIndex ?? 0
    }
    
    var moved: Bool = false
    
    var currentPlaceCoordinate: CLLocationCoordinate2D? = nil

//    init(currentPlaceCoordinate: CLLocationCoordinate2D) {
//        self.currentPlaceCoordinate = currentPlaceCoordinate
//        super.init(nibName: nil, bundle: nil)
//    }
    
    func showCurrentRoute() {
        guard let routeResponse = indexedRouteResponse,
              var prioritizedRoutes = routes else { return }
        
        prioritizedRoutes.insert(prioritizedRoutes.remove(at: currentRouteIndex), at: 0)
        
        // Show congestion levels on alternative route lines if there're multiple routes in the response.
        navigationMapView.showsCongestionForAlternativeRoutes = false
        navigationMapView.showsRestrictedAreasOnRoute = false
        navigationMapView.showcase(routeResponse)
        navigationMapView.showWaypoints(on: prioritizedRoutes.first!)
        navigationMapView.showRouteDurations(along: prioritizedRoutes)
        
        routeInfoLabel.text = "\(round(routes![currentRouteIndex].distance)) \(round(routes![currentRouteIndex].expectedTravelTime))"
        
        startButton.isHidden = false
        routeInfoLabel.isHidden = false
        profileImageView.isHidden = false
        
        if (!moved)
        {
            x![0].constant -= 116
            UIView.animate(withDuration: 0.28, delay: 0.1, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: {(_ completed: Bool) -> Void in
                self.moved = true
            })
        }
    }
    
    var currentRoute: Route? {
        return routes?[currentRouteIndex]
    }
    
    var routes: [Route]? {
        return indexedRouteResponse?.routeResponse.routes
    }
    
    
    var requestMapMatching = false
    
    var indexedRouteResponse: IndexedRouteResponse? {
        didSet {
            guard let routes = indexedRouteResponse?.routeResponse.routes, !routes.isEmpty else {
                clearNavigationMapView()
                return
            }
            showCurrentRoute()
        }
    }
    
    var profileIdentifier: ProfileIdentifier = .automobileAvoidingTraffic
    
    
    weak var passiveLocationManager: PassiveLocationManager?
    
    typealias RouteRequestSuccess = ((IndexedRouteResponse) -> Void)
    typealias RouteRequestFailure = ((Error) -> Void)
    typealias ActionHandler = (UIAlertAction) -> Void
    
    // MARK: - Initializer methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if navigationMapView == nil {
            navigationMapView = NavigationMapView(frame: .zero)
            navigationMapView.mapView.mapboxMap.onEvery(event: .styleLoaded) { [weak self] _ in
                self?.navigationMapView.localizeLabels()
            }
        }
    }
    
    deinit {
        if let navigationMapView = navigationMapView {
            uninstall(navigationMapView)
        }
    }
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestNotificationCenterAuthorization()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.currentPlaceCoordinate = nil
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc func backButtonPressed() {
        self.dismissDetail()
    }
    
    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
        let label = sender.view as! UILabel
        
        if(label.tag == 0)
        {
            let spvc = SearchPointViewController(isStartPoint: true)
            spvc.modalPresentationStyle = .fullScreen
            add(spvc, frame: view.bounds)
        }
        else
        {
            let spvc = SearchPointViewController(isStartPoint: false)
            spvc.modalPresentationStyle = .fullScreen
            add(spvc, frame: view.bounds)
        }
    }
    
    @objc func startButtonPressed(_ sender: Any) {
        
        guard let response = indexedRouteResponse,
              let route = response.currentRoute else{ return }
        
        let hudController = HUDController()
   
        hudController.modalPresentationStyle = .fullScreen
        
        hudController.indexedUserRouteResponse = response
        
        present(hudController, animated: true) {
            if let destinationCoordinate = route.shape?.coordinates.last {
                var destinationAnnotation = PointAnnotation(coordinate: destinationCoordinate)
                let markerImage = UIImage(named: "default_marker", in: .mapboxNavigation, compatibleWith: nil)!
                destinationAnnotation.image = .init(image: markerImage, name: "marker")
                hudController.destinationAnnotation = destinationAnnotation
            }
        }
        
        clearRoute()
    }
    
    @objc func performAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        
        let requestAutoDirections: ActionHandler = { _ in self.requestAutoDirections() }
        let requestAutoAvoidingTrafficDirections: ActionHandler = { _ in self.requestAutoAvoidingTrafficDirections() }
        let requestCyclingDirections: ActionHandler = { _ in self.requestCyclingDirections() }
        let clearRoute: ActionHandler = { _ in self.clearRoute() }
        
        
        let actions: [(String, UIAlertAction.Style, ActionHandler?)] = [
            ("Request Auto Directions", .default, requestAutoDirections),
            ("Request Auto Avoiding Traffic Directions", .default, requestAutoAvoidingTrafficDirections),
            ("Request Cycling Directions", .default, requestCyclingDirections),
            ("Clear Route", .destructive, clearRoute),
            ("Cancel", .cancel, nil),
        ]
        
        actions
            .map({ payload in UIAlertAction(title: payload.0, style: payload.1, handler: payload.2) })
            .forEach(alertController.addAction(_:))
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    func requestAutoDirections() {
        profileIdentifier = .automobile
        requestRoute()
    }
    
    func requestAutoAvoidingTrafficDirections() {
        profileIdentifier = .automobileAvoidingTraffic
        requestRoute()
    }
    
    func requestCyclingDirections() {
        profileIdentifier = .cycling
        requestRoute()
    }
    
    func clearRoute() {
        indexedRouteResponse = nil
        
        // move search box down
        if(moved){
            x![0].constant += 116
            UIView.animate(withDuration: 0.28, delay: 0.1, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            }, completion:  {(_ completed: Bool) -> Void in
                self.startButton.isHidden = true
                self.routeInfoLabel.isHidden = true
                self.profileImageView.isHidden = true
                self.moved = false
                self.currentPlaceCoordinate = nil
            })
        }
    }
    
    private func makeSearchViewControllerIfNeeded(isStartPoint: Bool) -> SearchPointViewController {
        let currentController = children.filter({ $0 is SearchPointViewController }).first as? SearchPointViewController
        let controller: SearchPointViewController = currentController ?? SearchPointViewController(isStartPoint: isStartPoint)
   

        return controller
    }
    
    var x: [NSLayoutConstraint]?

    private func configure(_ navigationMapView: NavigationMapView) {
        setupPassiveLocationProvider()
        
        navigationMapView.mapView.ornaments.options.scaleBar.visibility = OrnamentVisibility.hidden
        navigationMapView.mapView.ornaments.options.compass.visibility = OrnamentVisibility.hidden
        
        navigationMapView.delegate = self
        navigationMapView.userLocationStyle = .puck2D(configuration: Puck2DConfiguration.makeDefault(showBearing: true))
        
        setupGestureRecognizers()
        
        navigationMapView.mapView.camera.fly(to: .init(center: navigationMapView.mapView.cameraState.center,
                                                       zoom: navigationMapView.mapView.cameraState.zoom),
                                             duration: 0,
                                             completion: nil)
                
        navigationMapView.mapView.mapboxMap.style.uri = .streets
      
        view.addSubview(bottomView)
        view.addSubview(backButton)
        view.addSubview(optionsButton)
        view.addSubview(createRouteView)
        view.addSubview(startButton)
        bottomView.addSubview(routeInfoLabel)
        bottomView.addSubview(profileImageView)
        
        backButton.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: view.safeAreaInsets.top + 60, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 30)
        optionsButton.anchor(view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: view.safeAreaInsets.top + 60, leftConstant: 0, bottomConstant: 0, rightConstant: 12, widthConstant: 80, heightConstant: 30)
        bottomView.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: -10, rightConstant: 0, widthConstant: 0, heightConstant: 180)
        x = createRouteView.anchorWithReturnAnchors(bottomView.topAnchor, left: bottomView.leftAnchor, bottom: nil, right: bottomView.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 90)
        
        startButton.anchor(bottomView.topAnchor, left: nil, bottom: nil, right: bottomView.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 16, widthConstant: 80, heightConstant: 80)
        routeInfoLabel.anchor(nil, left: bottomView.leftAnchor, bottom: bottomView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 80, rightConstant: 0, widthConstant: 200, heightConstant: 35)
        
        createRouteView.addSubview(startLabel)
        createRouteView.addSubview(endLabel)
        
        startLabel.anchor(createRouteView.topAnchor, left: createRouteView.leftAnchor, bottom: nil, right: createRouteView.rightAnchor, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 45)
        endLabel.anchor(startLabel.bottomAnchor, left: createRouteView.leftAnchor, bottom: createRouteView.bottomAnchor, right: createRouteView.rightAnchor, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 45)
        
        routeInfoLabel.anchor(bottomView.topAnchor, left: bottomView.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 16, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 45)
        profileImageView.anchor(routeInfoLabel.bottomAnchor, left: bottomView.leftAnchor, bottom: nil, right: nil, topConstant: 5, leftConstant: 16, bottomConstant: 0, rightConstant: 0, widthConstant: 35, heightConstant: 35)
        
        if UserDefaults.standard.bool(forKey: "is_motorcycle_route_type") {
            profileImageView.image = UIImage(named: "bike")
        } else {
            profileImageView.image = UIImage(named: "bicycle")
        }
        
        startButton.isHidden = true
        routeInfoLabel.isHidden = true
        profileImageView.isHidden = true
        
        if(currentPlaceCoordinate != nil)
        {
            navigationMapView.mapView.camera.fly(to: .init(center: currentPlaceCoordinate!, zoom: 15), duration: 0.25, completion: nil)
            requestRouteFor(coordinate: currentPlaceCoordinate!)
        }

    }
    
    private func uninstall(_ navigationMapView: NavigationMapView) {
        unsubscribeFromFreeDriveNotifications()
        navigationMapView.removeFromSuperview()
    }
    
    private func clearNavigationMapView() {
        
        navigationMapView?.unhighlightBuildings()
        navigationMapView?.removeRoutes()
        navigationMapView?.removeRouteDurations()
        navigationMapView?.removeWaypoints()
        navigationMapView?.removeContinuousAlternativesRoutes()
        
        waypoints.removeAll()
        navigationMapView?.navigationCamera.follow()
    }
    
    func requestNotificationCenterAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { _, _ in
            DispatchQueue.main.async {
                CLLocationManager().requestWhenInUseAuthorization()
            }
        }
    }
    
    // MARK: - UIGestureRecognizer methods
    
    func setupGestureRecognizers() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        navigationMapView.gestureRecognizers?.filter({ $0 is UILongPressGestureRecognizer }).forEach(longPressGestureRecognizer.require(toFail:))
        navigationMapView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let gestureLocation = gesture.location(in: navigationMapView)
        let destinationCoordinate = navigationMapView.mapView.mapboxMap.coordinate(for: gestureLocation)
        
        requestRouteFor(coordinate: destinationCoordinate)
        reverseGeocodeCoordinate(coordinate: destinationCoordinate)
    }
    
    private func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        let options = ReverseGeocodeOptions(coordinate: coordinate)
               
        geocoder.geocode(options) { (placemarks, attribution, error) in
            guard let placemark = placemarks?.first else {
                return
            }
            self.endLabel.text = placemark.name
        }
    }
    
    public func requestRouteFor(coordinate: CLLocationCoordinate2D)
    {
        indexedRouteResponse = nil
        
        if waypoints.count > 1 {
            waypoints = Array(waypoints.dropFirst())
        }
        
        // Note: The destination name can be modified. The value is used in the top banner when arriving at a destination.
        let waypoint = Waypoint(coordinate: coordinate, name: "Dropped Pin #\(waypoints.endIndex + 1)")
        // Example of building highlighting. `targetCoordinate`, in this example,
        // is used implicitly by NavigationViewController to determine which buildings to highlight.
        waypoint.targetCoordinate = coordinate
        waypoints.append(waypoint)
        
//        // Example of highlighting buildings in 3d and directly using the API on NavigationMapView.
//        let buildingHighlightCoordinates = waypoints.compactMap { $0.targetCoordinate }
//        navigationMapView.highlightBuildings(at: buildingHighlightCoordinates)
        
        requestRoute()
    }
    
    func requestRoute() {
        guard waypoints.count > 0 else { return }
        guard let currentLocation = passiveLocationManager?.location else {
            print("User location is not valid. Make sure to enable Location Services.")
            return
        }
        
        let userWaypoint = Waypoint(location: currentLocation)
        if currentLocation.course >= 0 {
            userWaypoint.heading = currentLocation.course
            userWaypoint.headingAccuracy = 90
        }
        waypoints.insert(userWaypoint, at: 0)
        
        // Get periodic updates regarding changes in estimated arrival time and traffic congestion segments along the route line.
        RouteControllerProactiveReroutingInterval = 30
        
        if requestMapMatching {
            waypoints.forEach { $0.heading = nil }
            let mapMatchingOptions = NavigationMatchOptions(waypoints: waypoints, profileIdentifier: profileIdentifier)
            requestRoute(with: mapMatchingOptions, success: defaultSuccess, failure: defaultFailure)
        } else {
            let navigationRouteOptions = NavigationRouteOptions(waypoints: waypoints, profileIdentifier: profileIdentifier)
            requestRoute(with: navigationRouteOptions, success: defaultSuccess, failure: defaultFailure)
        }
    }
    
    fileprivate lazy var defaultSuccess: RouteRequestSuccess = { [weak self] (response) in
        guard let self = self,
              // In some rare cases this callback can be called when `NavigationMapView` object is no
              // longer available. This check prevents access to invalid object.
                self.navigationMapView != nil,
              let routes = response.routeResponse.routes,
              !routes.isEmpty else { return }
        self.navigationMapView.removeWaypoints()
        self.indexedRouteResponse = response
        
        // Waypoints which were placed by the user are rewritten by slightly changed waypoints
        // which are returned in response with routes.
        if let waypoints = response.routeResponse.waypoints {
            self.waypoints = waypoints
        }
    }
    
    fileprivate lazy var defaultFailure: RouteRequestFailure = { [weak self] (error) in
        // Clear routes from the map
        self?.indexedRouteResponse = nil
    }
    
    func requestRoute(with options: RouteOptions, success: @escaping RouteRequestSuccess, failure: RouteRequestFailure?) {
        MapboxRoutingProvider().calculateRoutes(options: options) { (result) in
            switch result {
            case let .success(response):
                success(response)
            case let .failure(error):
                failure?(error)
            }
        }
    }
    
    func requestRoute(with options: MatchOptions, success: @escaping RouteRequestSuccess, failure: RouteRequestFailure?) {
        MapboxRoutingProvider().calculateRoutes(options: options) { (_, result) in
            switch result {
            case let .success(response):
                do {
                    success(.init(routeResponse: try RouteResponse(matching: response,
                                                                   options: options,
                                                                   credentials: response.credentials),
                                  routeIndex: 0))
                } catch {
                    failure?(DirectionsError.noMatches)
                }
            case let .failure(error):
                failure?(error)
            }
        }
    }
    
    func navigationViewController(navigationService: NavigationService) -> NavigationViewController {
        let navigationOptions = NavigationOptions(navigationService: navigationService, predictiveCacheOptions: PredictiveCacheOptions())
        
        let navigationViewController = NavigationViewController(for: navigationService.indexedRouteResponse,
                                                                navigationOptions: navigationOptions)
        navigationViewController.delegate = self
        
        var roadClassesToAvoid: RoadClasses = []
         
        if UserDefaults.standard.bool(forKey: "is_avoid_motorways_checked") {
            roadClassesToAvoid.insert(.motorway)
        }
        if UserDefaults.standard.bool(forKey: "is_avoid_ferries_checked") {
            roadClassesToAvoid.insert(.ferry)
        }
        if UserDefaults.standard.bool(forKey: "is_avoid_tolls_checked") {
            roadClassesToAvoid.insert(.toll)
        }
        
        navigationViewController.navigationService.routeProgress.routeOptions.roadClassesToAvoid = roadClassesToAvoid
        
        if UserDefaults.standard.bool(forKey: "is_metric_measurement_system")  {
            navigationViewController.navigationService.routeProgress.routeOptions.distanceMeasurementSystem = .metric
        } else {
            navigationViewController.navigationService.routeProgress.routeOptions.distanceMeasurementSystem = .imperial
        }
        
        return navigationViewController
    }
    
    func navigationService(indexedRouteResponse: IndexedRouteResponse) -> NavigationService {
        return MapboxNavigationService(indexedRouteResponse: indexedRouteResponse,
                                       customRoutingProvider: nil,
                                       credentials: NavigationSettings.shared.directions.credentials,
                                       simulating: .always)
    }
    
    // MARK: - Utility methods
    func presentAlert(_ title: String? = nil, message: String? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - NavigationMapViewDelegate methods

extension RideController: NavigationMapViewDelegate {
    
    func navigationMapView(_ mapView: NavigationMapView, didSelect waypoint: Waypoint) {
        guard let responseOptions = indexedRouteResponse?.routeResponse.options else { return }
        
        switch responseOptions {
        case .route(let routeOptions):
            let modifiedOptions: RouteOptions = routeOptions.without(waypoint) as! RouteOptions
            presentWaypointRemovalAlert { _ in
                self.requestRoute(with:modifiedOptions, success: self.defaultSuccess, failure: self.defaultFailure)
            }
        case .match(let matchOptions):
            let modifiedOptions: MatchOptions = matchOptions.without(waypoint) as! MatchOptions
            presentWaypointRemovalAlert { _ in
                self.requestRoute(with:modifiedOptions, success: self.defaultSuccess, failure: self.defaultFailure)
            }
        }
    }
    
    func navigationMapView(_ navigationMapView: NavigationMapView, didSelect continuousAlternative: AlternativeRoute) {
        indexedRouteResponse?.routeIndex = continuousAlternative.indexedRouteResponse.routeIndex
    }
    
    private func presentWaypointRemovalAlert(completionHandler approve: @escaping ((UIAlertAction) -> Void)) {
        let title = NSLocalizedString("REMOVE_WAYPOINT_CONFIRM_TITLE",
                                      value: "Remove Waypoint?",
                                      comment: "Title of alert confirming waypoint removal")
        
        let message = NSLocalizedString("REMOVE_WAYPOINT_CONFIRM_MSG",
                                        value: "Do you want to remove this waypoint?",
                                        comment: "Message of alert confirming waypoint removal")
        
        let removeTitle = NSLocalizedString("REMOVE_WAYPOINT_CONFIRM_REMOVE",
                                            value: "Remove Waypoint",
                                            comment: "Title of alert action for removing a waypoint")
        
        let cancelTitle = NSLocalizedString("REMOVE_WAYPOINT_CONFIRM_CANCEL",
                                            value: "Cancel",
                                            comment: "Title of action for dismissing waypoint removal confirmation sheet")
        
        let waypointRemovalAlertController = UIAlertController(title: title,
                                                               message: message,
                                                               preferredStyle: .alert)
        
        let removeAction = UIAlertAction(title: removeTitle,
                                         style: .destructive,
                                         handler: approve)
        
        let cancelAction = UIAlertAction(title: cancelTitle,
                                         style: .cancel,
                                         handler: nil)
        
        [removeAction, cancelAction].forEach(waypointRemovalAlertController.addAction(_:))
        
        self.present(waypointRemovalAlertController, animated: true, completion: nil)
    }
}

// MARK: - NavigationViewControllerDelegate methods

extension RideController: NavigationViewControllerDelegate {
    
    // To modify the width of the alternative route line layer through delegate methods.
    func navigationViewController(_ navigationViewController: NavigationViewController, willAdd layer: Layer) -> Layer? {
        guard var lineLayer = layer as? LineLayer else { return nil }
        if lineLayer.id.contains("alternative.route_line") {
            lineLayer.lineWidth = .expression(
                Exp(.interpolate) {
                    Exp(.linear)
                    Exp(.zoom)
                    RouteLineWidthByZoomLevel.multiplied(by: 0.7)
                }
            )
        }
        if lineLayer.id.contains("alternative.route_line_casing") {
            lineLayer.lineWidth = .expression(
                Exp(.interpolate) {
                    Exp(.linear)
                    Exp(.zoom)
                    RouteLineWidthByZoomLevel
                }
            )
        }
        return lineLayer
    }
    
    func navigationViewController(_ navigationViewController: NavigationViewController, didArriveAt waypoint: Waypoint) -> Bool {
        return true
    }
    
    func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
        clearNavigationMapView()
    }
}


// MARK: - Free-driving methods

extension RideController {
    
    func setupPassiveLocationProvider() {
        let passiveLocationManager = PassiveLocationManager()
        self.passiveLocationManager = passiveLocationManager
        
        let passiveLocationProvider = PassiveLocationProvider(locationManager: passiveLocationManager)
        navigationMapView.mapView.location.overrideLocationProvider(with: passiveLocationProvider)
        
        subscribeForFreeDriveNotifications()
    }
    
    func subscribeForFreeDriveNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didUpdatePassiveLocation),
                                               name: .passiveLocationManagerDidUpdate,
                                               object: nil)
    }
    
    func unsubscribeFromFreeDriveNotifications() {
        NotificationCenter.default.removeObserver(self, name: .passiveLocationManagerDidUpdate, object: nil)
    }
    
    @objc func didUpdatePassiveLocation(_ notification: Notification) {
        if let location = notification.userInfo?[PassiveLocationManager.NotificationUserInfoKey.locationKey] as? CLLocation {
            navigationMapView.moveUserLocation(to: location, animated: true)
        }
    }
}


