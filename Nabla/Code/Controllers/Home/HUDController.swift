//
//  HUDController.swift
//  ble-tbt-navigation-ios
//
//  Created by Jaksa Tomovic on 16.08.2023..
//

import Foundation
import UIKit
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import MapboxMaps
import Toast



class HUDController: ContainerViewController {
    
    @objc dynamic public var valueTextColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) {
        didSet {
            update()
        }
    }
    
    @objc dynamic public var unitTextColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) {
        didSet {
            update()
        }
    }
    
    @objc dynamic public var valueTextColorHighlighted: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) {
        didSet {
            update()
        }
    }
    
    @objc dynamic public var unitTextColorHighlighted: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) {
        didSet {
            update()
        }
    }
    
    @objc dynamic public var valueFont: UIFont = UIFont.systemFont(ofSize: 36, weight: .heavy) {
        didSet {
            update()
        }
    }
    
    @objc dynamic public var unitFont: UIFont = UIFont.systemFont(ofSize: 22, weight: .regular) {
        didSet {
            update()
        }
    }
    
//    let hrmRateChar = LittleBlueToothCharacteristic(characteristic: BLECostants.uuidCharForIndicate, for: BLECostants.uuidService, properties: .notify)
//    let hrmSensorChar = LittleBlueToothCharacteristic(characteristic: BLECostants.uuidCharForRead, for: BLECostants.uuidService, properties: .read)
//    let hrmControlPointChar = LittleBlueToothCharacteristic(characteristic: BLECostants.uuidCharForWrite, for: BLECostants.uuidService, properties: .writeWithoutResponse)
    
    var encoder = DataEncoder()
    var currentData = Data()
    var lastData = Data()
    var navigationService: NavigationService!
    var currentLegIndex: Int = 0
    var indexedUserRouteResponse: IndexedRouteResponse?

    
    
    var destinationAnnotation: PointAnnotation! {
        didSet {
            pointAnnotationManager?.annotations = [destinationAnnotation]
        }
    }
    
    let distanceFormatter = DistanceFormatter()
    
    public var distance: CLLocationDistance? {
        didSet {
            attributedDistanceString = nil
            if let distance = distance {
                attributedDistanceString = distanceFormatter.attributedString(for: distance)
            } else {
                distanceLabel.text = nil
            }
        }
    }
    
    var attributedDistanceString: NSAttributedString? {
        didSet {
            update()
        }
    }
    
    var eta: String? {
        get {
            return etaLabel.text
        }
        set {
            etaLabel.text = newValue
        }
    }
    
    var totalDistance: String? {
        get {
            return totalDistanceLabel.text
        }
        set {
            totalDistanceLabel.text = newValue
        }
    }
    
    var speedLimit: String? {
        get {
            return speedLimitSign.titleLabel?.text
        }
        set {
            speedLimitSign.setTitle(newValue, for: .normal)
        }
    }
    
    var maneuverView: ManeuverView = {
        let view = ManeuverView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let distanceLabel: DistanceLabel = {
        let label = DistanceLabel()
        label.backgroundColor = .clear
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 16.0 / 22.0
        return label
    }()
    
    lazy var bottomView: UIView = {
        let view = UITableView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.9)
        view.tintColor = .white
        view.isScrollEnabled = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 30
        return view
    }()
    
    lazy var stopNavigationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(stopNavigationButtonPressed), for: .touchUpInside)
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        return button
    }()
    
    let etaLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    let totalDistanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    let speedLimitSign: UIButton = {
        let button = UIButton()
        button.setTitle("30", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        button.tintColor = .black
        button.backgroundColor = .white
        button.layer.cornerRadius = 30
        button.clipsToBounds = true
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.borderWidth = 5
        return button
    }()
    
    var pointAnnotationManager: PointAnnotationManager?
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        view.addSubview(maneuverView)
        view.addSubview(bottomView)
        view.addSubview(stopNavigationButton)
        view.addSubview(etaLabel)
        view.addSubview(totalDistanceLabel)
        
        maneuverView.addSubview(distanceLabel)
        distanceLabel.layer.zPosition = 1000
        
        maneuverView.primaryColor = .white
        
        maneuverView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        bottomView.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 180)
        distanceLabel.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: view.safeAreaInsets.top + 120, leftConstant: view.frame.size.width/2 - 100, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 50)
        stopNavigationButton.anchor(nil, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: view.safeAreaInsets.bottom + 50, rightConstant: 24, widthConstant: 50, heightConstant: 50)
        etaLabel.anchor(bottomView.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 15, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 50)
        totalDistanceLabel.anchor(bottomView.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 15, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 50)
        
        
        view.addSubview(speedLimitSign)
        speedLimitSign.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: view.safeAreaInsets.top + 80, leftConstant: 24, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 60)
        
        
        
        navigationService = MapboxNavigationService(indexedRouteResponse: indexedUserRouteResponse!,
                                                    customRoutingProvider: nil,
                                                    credentials: NavigationSettings.shared.directions.credentials,
                                                    locationSource: NavigationLocationManager(),
                                                    simulating:  .inTunnels)
        
        
        navigationService.routeProgress.routeOptions.roadClassesToAvoid = [.ferry,.toll,.motorway]
        
        resumeNotifications()
        navigationService.delegate = self
        
        navigationService.start()
        
//        options.roadClassesToAvoid = .toll (or .motorway or .ferry).
    }
    
    deinit {
        navigationService.stop()
        suspendNotifications()
    }
    
    func resumeNotifications() {
        // Add observers for the route refresh, rerouting and route progress update events to update the main route line
        // when `NavigationMapView.routeLineTracksTraversal` set to `true`.
        NotificationCenter.default.addObserver(self, selector: #selector(progressDidChange(_ :)), name: .routeControllerProgressDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateInstructionsBanner(notification:)), name: .routeControllerDidPassVisualInstructionPoint, object: navigationService.router)
    }
    
    func suspendNotifications() {
        NotificationCenter.default.removeObserver(self, name: .routeControllerProgressDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .routeControllerDidPassVisualInstructionPoint, object: nil)
    }
    
    // Notifications sent on all location updates
    @objc func progressDidChange(_ notification: NSNotification) {
        // do not update if we are previewing instruction steps
        guard let routeProgress = notification.userInfo?[RouteController.NotificationUserInfoKey.routeProgressKey] as? RouteProgress else { return }
        
        let speedLimit = Int(floor(round(Double(routeProgress.currentLegProgress.currentSpeedLimit?.value ?? 0.0))))
        
        let etaX = Int(round(routeProgress.durationRemaining / 60))
        var totalDistance = round(routeProgress.route.distance)
        let maneuverDirection = routeProgress.currentLegProgress.currentStepProgress.currentVisualInstruction?.primaryInstruction.maneuverDirection?.rawValue ?? ""
        let maneuverType = routeProgress.currentLegProgress.currentStepProgress.currentVisualInstruction?.primaryInstruction.maneuverType?.rawValue ?? ""
        let maneuver = maneuverType + " " + maneuverDirection
        let progress =  round(routeProgress.fractionTraveled)
        let imageName = "direction_" + maneuverType.replacingOccurrences(of: " ", with: "_") + "_" + maneuverDirection

        let imgNumber = getImageNumber(img: imageName)

        
        updateDistance(for: routeProgress.currentLegProgress.currentStepProgress)

        
        maneuverView.visualInstruction =  routeProgress.currentLegProgress.currentStepProgress.currentVisualInstruction?.primaryInstruction
        maneuverView.drivingSide = routeProgress.currentLegProgress.currentStepProgress.currentVisualInstruction?.drivingSide ?? .right
        
        self.eta = "~\(etaX) min"
        
        if(totalDistance.magnitude >= 1000)
        {
            totalDistance = round(totalDistance.magnitude/1000)
            let x = Int(totalDistance)
            self.totalDistance = "\(x)\(navigationService.routeProgress.routeOptions.distanceMeasurementSystem.rawValue == "imperial" ? "mi" : "km")"

        }else
        {
            totalDistance = round(totalDistance.magnitude/1000)
            let x = Int(totalDistance)
            self.totalDistance = "\n\(x)\(navigationService.routeProgress.routeOptions.distanceMeasurementSystem.rawValue == "imperial" ? "feet" : "m")"

        }
        
        if(speedLimit == 0)
        {
            speedLimitSign.isHidden = true
        }
        else
        {
            speedLimitSign.isHidden = false
        }

        sendCommand(command: InstructionCommand(maneuver: maneuver, junctionDistance: attributedDistanceString?.string ?? "", speedLimit: speedLimit, eta: etaX, progress: progress, totalDistance: self.totalDistance!, image: "\(imgNumber)"))
        
        currentLegIndex = routeProgress.legIndex
        
        
    }
    
    public func updateDistance(for currentStepProgress: RouteStepProgress) {
        let distanceRemaining = currentStepProgress.distanceRemaining
        distance = distanceRemaining > 5 ? distanceRemaining : 0
    }
    
    @objc func updateInstructionsBanner(notification: NSNotification) {
        guard let routeProgress = notification.userInfo?[RouteController.NotificationUserInfoKey.routeProgressKey] as? RouteProgress else {
            assertionFailure("RouteProgress should be available.")
            return
        }
        
        
        let speedLimit = Int(floor(round(Double(routeProgress.currentLegProgress.currentSpeedLimit?.value ?? 0.0))))
        let eta = Int(round(routeProgress.durationRemaining / 60))
        var totalDistance = round(routeProgress.route.distance)
        let maneuverDirection = routeProgress.currentLegProgress.currentStepProgress.currentVisualInstruction?.primaryInstruction.maneuverDirection?.rawValue ?? ""
        let maneuverType = routeProgress.currentLegProgress.currentStepProgress.currentVisualInstruction?.primaryInstruction.maneuverType?.rawValue ?? ""
        let maneuver = maneuverType + " " + maneuverDirection
        let progress =  round(routeProgress.fractionTraveled)
        let imageName = "direction_" + maneuverType.replacingOccurrences(of: " ", with: "_") + "_" + maneuverDirection

        print(imageName)

        let imgNumber = getImageNumber(img: imageName)
        
        self.speedLimit = "\(speedLimit)"
        if(totalDistance.magnitude >= 1000)
        {
            totalDistance = round(totalDistance.magnitude/1000)
            let x = Int(totalDistance)
            self.totalDistance = "\(x)km"

        }else
        {
            totalDistance = round(totalDistance.magnitude/1000)
            let x = Int(totalDistance)
            self.totalDistance = "\(x)m"

        }
        if(speedLimit == 0)
        {
            speedLimitSign.isHidden = true
        }
        else
        {
            speedLimitSign.isHidden = false
        }

        
        maneuverView.visualInstruction =  routeProgress.currentLegProgress.currentStepProgress.currentVisualInstruction?.primaryInstruction
        maneuverView.drivingSide = routeProgress.currentLegProgress.currentStepProgress.currentVisualInstruction?.drivingSide ?? .right
        
        updateDistance(for: routeProgress.currentLegProgress.currentStepProgress)
        
        sendCommand(command: InstructionCommand(maneuver: maneuver , junctionDistance: attributedDistanceString?.string ?? "", speedLimit: speedLimit, eta: eta, progress: progress, totalDistance: self.totalDistance!, image: "\(imgNumber)"))

        print("daasdasdasdasdas")
        
    }
    
    @objc func stopNavigationButtonPressed(_ sender: Any) {
        let alert = UIAlertController(
            title: "End your ride?",
            message: nil,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (test) -> Void in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present( alert, animated: true, completion: nil)
    }
    
    func navigationService(_ service: NavigationService, didArriveAt waypoint: Waypoint) -> Bool {
        let isFinalLeg = service.routeProgress.isFinalLeg
        if isFinalLeg {
            let alert = UIAlertController(title: "Arrived at \(waypoint.name ?? "final desstination").", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
            return true
        }
        return false
    }
    
    func update() {
        guard let attributedDistanceString = attributedDistanceString else {
            return
        }
        
        // Create a copy of the attributed string that emphasizes the quantity.
        let emphasizedDistanceString = NSMutableAttributedString(attributedString: attributedDistanceString)
        let wholeRange = NSRange(location: 0, length: emphasizedDistanceString.length)
        var hasQuantity = false
        emphasizedDistanceString.enumerateAttribute(.quantity, in: wholeRange, options: .longestEffectiveRangeNotRequired) { (value, range, stop) in
            let foregroundColor: UIColor
            let font: UIFont
            if let _ = emphasizedDistanceString.attribute(.quantity, at: range.location, effectiveRange: nil) {
                foregroundColor = true ? valueTextColorHighlighted : valueTextColor
                font = valueFont
                hasQuantity = true
            } else {
                foregroundColor = true ? unitTextColorHighlighted : unitTextColor
                font = unitFont
            }
            emphasizedDistanceString.addAttributes([.foregroundColor: foregroundColor, .font: font], range: range)
        }
        
        // As a failsafe, if no quantity was found, emphasize the entire string.
        if !hasQuantity {
            emphasizedDistanceString.addAttributes([.foregroundColor: valueTextColor, .font: valueFont], range: wholeRange)
        }
        
        // Replace spaces with hair spaces to economize on horizontal screen
        // real estate. Formatting the distance with a short style would remove
        // spaces, but in English it would also denote feet with a prime
        // mark (′), which is typically used for heights, not distances.
        emphasizedDistanceString.mutableString.replaceOccurrences(of: " ", with: "\u{200A}", options: [], range: wholeRange)
        
        distanceLabel.attributedText = emphasizedDistanceString
    }
}
