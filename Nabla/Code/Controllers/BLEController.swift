//
//  BLEController.swift
//  ble-tbt-navigation-ios
//
//  Created by Jaksa Tomovic on 23.08.2023..
//
import UIKit
import MapboxMaps
import Bluejay

class BLEController: UIViewController {
    
    private var encoder = DataEncoder()
    private var currentData = Data()
    private var lastData = Data()
    
    var sensors: [ScanDiscovery] = []
    var selectedSensor: PeripheralIdentifier?
    
    let labelTitle: UILabel = {
        let label = UILabel()
        label.text = "Connect device"
        label.textColor = .black
        label.backgroundColor = .white
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    let labelSubtitle: UILabel = {
        let label = UILabel()
        label.text = "Looking for a Nabla, is it on and nearby?"
        label.textColor = .black
        label.backgroundColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    var deviceImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "logo.bluetooth")!.withRenderingMode(.alwaysTemplate))
        iv.backgroundColor = .white
        iv.tintColor = .black
        return iv
    }()
    
    var deviceImage: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.cornerRadius = 80
        button.clipsToBounds = true
        button.tintColor = .black
        button.setTitle("· · ·", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 42, weight: .heavy)
        button.layer.borderWidth = 15
        button.layer.borderColor = UIColor.black.cgColor
        return button
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.tintColor = .black
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        self.hidesBottomBarWhenPushed = true
        bluejay.register(connectionObserver: self)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(deviceImage)
        view.addSubview(labelTitle)
        view.addSubview(labelSubtitle)
        view.addSubview(closeButton)
        
        closeButton.anchor(view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: view.safeAreaInsets.top + 50, leftConstant: 0, bottomConstant: 0, rightConstant: 16, widthConstant: 35, heightConstant: 35)
        
        deviceImage.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: view.safeAreaInsets.top + 80, leftConstant: view.frame.size.width/2 - 80, bottomConstant: 0, rightConstant: 0, widthConstant: 160, heightConstant: 160)
        
        labelTitle.anchor(deviceImage.bottomAnchor, left: view.centerXAnchor, bottom: nil, right: nil, topConstant: 5, leftConstant: -100, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 100)
        
        labelSubtitle.anchorCenterSuperview()
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidResume),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        bluejay.registerDisconnectHandler(handler: self)
        
        scanHeartSensors()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hidesBottomBarWhenPushed = false
        bluejay.unregister(connectionObserver: self)
    }
    
    @objc func appDidResume() {
        scanHeartSensors()
    }
    
    @objc func appDidBackground() {
        bluejay.stopScanning()
    }
    
    private func scanHeartSensors() {
        if !bluejay.isScanning && !bluejay.isConnecting && !bluejay.isConnected {
            let heartRateService = ServiceIdentifier(uuid: BLECostants.uuidService)
            
            bluejay.scan(
                duration: 3,
                allowDuplicates: false,
                serviceIdentifiers: [heartRateService],
                discovery: { [weak self] _, discoveries -> ScanAction in
                    guard let weakSelf = self else {
                        return .stop
                    }
                    
                    weakSelf.sensors = discoveries
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTableDevice"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deviceConnected"), object: nil)
                    return .continue
                },
                expired: { [weak self] lostDiscovery, discoveries -> ScanAction in
                    guard let weakSelf = self else {
                        return .stop
                    }
                    
                    print("Lost discovery: \(lostDiscovery)")
                    
                    weakSelf.sensors = discoveries
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTableDevice"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deviceConnected"), object: nil)
                    return .continue
                },
                stopped: { _, error in
                    if let error = error {
                        print("Scan stopped with error: \(error.localizedDescription)")
                    } else {
                        print("Scan stopped without error")
                        
                        if(self.sensors.isEmpty)
                        {
                            
                            let alert = UIAlertController(
                                title: "No Nablas found",
                                message: nil,
                                preferredStyle: .actionSheet)
                            alert.addAction(UIAlertAction(title: "Keep searching", style: .cancel, handler: { (test) -> Void in
                                self.sensors.removeAll()
                                self.scanHeartSensors()
                                // TODO FIX THIS with flag
                            }))
                            
                            self.present( alert, animated: true, completion: nil)
                        }
                        else {
                            let alertController = UIAlertController(title: "Nabla devices", message: nil, preferredStyle: .actionSheet)
                            self.sensors.map({ payload in UIAlertAction(title: "NablaMoto \(payload.peripheralIdentifier.name )" , style: .default, handler: {_ in
                                self.labelTitle.text = "Connecting device"
                                self.labelTitle.adjustsFontSizeToFitWidth = true
                                self.labelSubtitle.text = "Connected, Waiting for Pairing"
                                self.selectedSensor = payload.peripheralIdentifier
                                self.sensors.removeAll()
                                self.connect()
                            }) }).forEach(alertController.addAction(_:))
                            
                            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                            
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                    
                })
        }
    }
    
    func connect() {
        bluejay.connect(selectedSensor!, timeout: .seconds(15)) { result in
            switch result {
            case .success:
                print("Connection attempt to: \(self.selectedSensor!.description) is successful")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deviceConnected"), object: nil)
                self.lastData = Data()
                self.checkFirmware()
                UserDefaults.standard.setValue(self.selectedSensor!.uuid.uuidString, forKey: "peripheral_uuid")
            case .failure(let error):
                print("Failed to connect to: \(self.selectedSensor!.description) with error: \(error.localizedDescription)")
            }
        }
    }
    
    func checkFirmware() {
        let heartRateService = ServiceIdentifier(uuid: BLECostants.uuidService)
        let sensorLocation = CharacteristicIdentifier(uuid: BLECostants.uuidCharForRead, service: heartRateService)
        
        bluejay.read(from: sensorLocation) { [weak self] (result: ReadResult<HeartRateMeasurement>) in
            guard let weakSelf = self else {
                return
            }
            
            switch result {
            case .success(let data):
                debugPrint("Read from sensor location is successful: \(data)")
                weakSelf.labelSubtitle.text = "Finishing connection"
                // store it
                weakSelf.getDeviceInfo(info: data.info)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTableDevice"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deviceConnected"), object: nil)
                weakSelf.dismiss(animated: true)
            case .failure(let error):
                debugPrint("Failed to read sensor location with error: \(error.localizedDescription)")
            }
        }
    }
    
    func getDeviceInfo(info: String) {
        let ch = Character("|")
        let result = info.split(separator: ch)
        
        // Access Shared Defaults Object
        let userDefaults = UserDefaults.standard

        // Write/Set Value
        userDefaults.set(result[0], forKey: "nabla_device_name")
        userDefaults.set(result[1], forKey: "nabla_firmware_version")
        print("Result : \(result)")
    }
    
    func disconnect() {
        bluejay.disconnect(immediate: true) { (_) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deviceConnected"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTableDevice"), object: nil)
        }
    }
    
//    func readBatteryLevel() {
//        StartLittleBlueTooth
//            .read(for: self.littleBT, from: uuidCharForRead)
//            .sink(receiveCompletion: { (result) in
//                print("Result: \(result)")
//                switch result {
//                case .finished:
//                    break
//                case .failure(let error):
//                    print("Error while changing sensor position: \(error)")
//                    break
//                }
//
//            }) { (value: NablaDeviceResponse) in
////                let toast = Toast.text("\(value.position)")
////                toast.show(haptic: .warning, after: 0)
//            }
//            .store(in: &disposeBag)
//    }
    
    func appendLog(_ message: String) {
        let timeFormatter = DateFormatter()
        let logLine = "\(timeFormatter.string(from: Date())) \(message)"
        print("DEBUG: \(logLine)")
    }
    
    @objc func closeButtonPressed()
    {
        dismiss(animated: true)
    }
}

extension BLEController: ConnectionObserver {
    func bluetoothAvailable(_ available: Bool) {
        print("ScanViewController - Bluetooth available: \(available)")

        if available {
            scanHeartSensors()
        } else if !available {
            sensors = []
//            tableView.reloadData()
        }
    }

    func connected(to peripheral: PeripheralIdentifier) {
        print("ScanViewController - Connected to: \(peripheral.description)")
//        performSegue(withIdentifier: "showSensor", sender: self)
//        checkFirmware()
    }
}

extension BLEController: DisconnectHandler {
    func didDisconnect(from peripheral: PeripheralIdentifier, with error: Error?, willReconnect autoReconnect: Bool) -> AutoReconnectMode {
        if navigationController?.topViewController is BLEController {
            scanHeartSensors()
        }

        return .noChange
    }
}
