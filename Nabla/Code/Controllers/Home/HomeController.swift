//
//  RideController.swift
//  ble-tbt-navigation-ios
//
//  Created by Jaksa Tomovic on 21.08.2023..
//

import UIKit
import MapboxMaps
import MapboxSearch
import UserNotifications
import Bluejay

class HomeController: UIViewController, UITableViewDelegate, AddPlaceButtonDelegate {
    
    fileprivate let cellId = "cellId"
    fileprivate let emptyCellId = "emptyCellId"
    fileprivate let sectionHeaderId = "sectionHeader"
    fileprivate let sectionFooterId = "sectionFooterId"
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .white
        tv.tintColor = .black
        tv.separatorStyle = .none
        tv.sectionHeaderTopPadding = 0
        return tv
    }()
    
    lazy var headerView: UIView = {
        let view = UITableView()
        view.backgroundColor = .white
        view.tintColor = .black
        view.isScrollEnabled = false
        return view
    }()
    
    lazy var footerView: UIView = {
        let view = UITableView()
        view.backgroundColor = UIColor(white: 1.0, alpha: 0)
        view.tintColor = .black
        view.isScrollEnabled = false
        return view
    }()
    
    lazy var logoImageView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "arrowtriangle.down"))
        view.backgroundColor = UIColor(white: 1.0, alpha: 0)
        view.contentMode = .scaleAspectFit
        view.tintColor = .black
        return view
    }()
    
    lazy var dotsImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "dots")?.withRenderingMode(.alwaysTemplate))
        view.backgroundColor = UIColor(white: 0.5, alpha: 0)
        view.contentMode = .scaleToFill
        view.tintColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 0.6)
        return view
    }()
    
    lazy var floatingButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setImage(UIImage(systemName: "mappin"), for: .normal)
        button.tintColor =  .white
        button.setTitle(" Plan Ride", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(planRideButtonPressed), for: .touchUpInside)
        button.semanticContentAttribute = .forceLeftToRight
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        button.layer.masksToBounds = false
        button.layer.shadowRadius = 2.0
        button.layer.shadowOpacity = 0.5
        return button
    }()
    
    lazy var deviceButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(white: 1, alpha: 0)
        button.setImage(UIImage(named: "logo.bluetooth"), for: .normal)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.addTarget(self, action: #selector(deviceButtonPressed), for: .touchUpInside)
        return button
    }()
    
    typealias ActionHandler = (UIAlertAction) -> Void
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        tabBarController?.hidesBottomBarWhenPushed = false
        loadPlacesFromUserDefaults()
        bluejay.register(connectionObserver: self)
        
        if UserDefaults.standard.bool(forKey: "is_onboarded") != true {
            print("nije onboardan")
            UserDefaults.standard.set(true, forKey: "is_onboarded")
        }
    }
    
    func loadPlacesFromUserDefaults() {
        print(places.count)
        print(places.isEmpty)
        let userDefaults = UserDefaults.standard
        if let savedData = userDefaults.object(forKey: "places") as? Data {
            do {
                let savedPlaces = try JSONDecoder().decode([Place].self, from: savedData)
                print(savedPlaces.count)
                places.removeAll(keepingCapacity: false)
                places.append(contentsOf: savedPlaces)
            } catch {
                // Failed to convert Data to Contact
            }
        }
    }
    
    var sensor: PeripheralIdentifier?
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(headerView)
        view.addSubview(tableView)
        view.addSubview(footerView)
        
        footerView.addSubview(floatingButton)
        headerView.addSubview(dotsImageView)
        headerView.addSubview(deviceButton)
        headerView.addSubview(logoImageView)
        
        headerView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 160)
        tableView.anchor(headerView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        footerView.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 5, rightConstant: 0, widthConstant: 0, heightConstant: 70)
        
        floatingButton.anchorCenterSuperview()
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        floatingButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        floatingButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        dotsImageView.anchor(view.topAnchor, left: nil, bottom: tableView.topAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 16, rightConstant: 0, widthConstant: 160, heightConstant: 0)
        
        deviceButton.anchor(view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: view.safeAreaInsets.top + 80, leftConstant: 0, bottomConstant: 0, rightConstant: 16, widthConstant: 40, heightConstant: 40)
        
        logoImageView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: view.safeAreaInsets.top + 70, leftConstant: 16, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 60)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        tableView.register(PlaceRouteCell.self, forCellReuseIdentifier: cellId)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: emptyCellId)
        tableView.register(TableSectionHeader.self, forHeaderFooterViewReuseIdentifier: sectionHeaderId)
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: sectionFooterId)
        
        setupDeviceButtonImage()
                
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDeviceImage), name: NSNotification.Name(rawValue: "deviceConnected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPlaces), name: NSNotification.Name(rawValue: "reloadPlaces"), object: nil)

    }
    
    @objc func reloadPlaces()
    {
        loadPlacesFromUserDefaults()
        tableView.reloadSections([0], with: .automatic)
    }
    
    @objc func reloadDeviceImage()
    {
        setupDeviceButtonImage()
    }
    
    func setupDeviceButtonImage()
    {
        if bluejay.isConnected
        {
            deviceButton.backgroundColor = .black
            deviceButton.tintColor = .white
            deviceButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
            deviceButton.layer.cornerRadius = 20
            deviceButton.clipsToBounds = true
            deviceButton.isUserInteractionEnabled = false
        }
        else
        {
            deviceButton.backgroundColor = UIColor(white: 1, alpha: 0)
            deviceButton.setImage(UIImage(named: "logo.bluetooth"), for: .normal)
            deviceButton.layer.cornerRadius = 20
            deviceButton.clipsToBounds = true
            deviceButton.layer.borderWidth = 1
            deviceButton.layer.borderColor = UIColor.black.cgColor
            deviceButton.isUserInteractionEnabled = true
        }
    }
    
    @objc func planRideButtonPressed()
    {
        let rideController = RideController()
        rideController.modalPresentationStyle = .fullScreen
        rideController.modalTransitionStyle = .crossDissolve
        navigationController?.presentDetail(rideController)
    }
  
    func addPlaceButtonPressed(header: TableSectionHeader)
    {
        let addPlaceController = AddPlaceController()
        addPlaceController.modalPresentationStyle = .fullScreen
        navigationController?.presentDetail(addPlaceController)
    }
    
    @objc func deviceButtonPressed()
    {
        let ble = BLEController()
        ble.modalPresentationStyle = .fullScreen
        navigationController?.present(ble, animated: true, completion: nil)
    }
}

extension HomeController: UITableViewDataSource, PlaceRouteCellDelegate, PlaceRouteLabelDelegate {

    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //2
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if(section == 0)
//        {
            if(places.isEmpty)
            {
                return 2
            }
            return places.count
//        }
//        else
//        {
//            if(routes.isEmpty)
//            {
//                return 2
//            }
//            return routes.count
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0)
        {
            if (places.isEmpty)
            {
                
                    let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellId, for: indexPath)
                    
                    cell.selectionStyle = .none
                    cell.textLabel!.textAlignment = .left
                    cell.textLabel!.textColor = .gray
                    cell.textLabel!.numberOfLines = 0
                    if(indexPath.row == 1)
                    {
                        cell.textLabel!.text = "You haven't got any favourites yet.\nTap 'Add place' to add one."
                        cell.textLabel!.numberOfLines = 0
                        cell.textLabel!.adjustsFontSizeToFitWidth = true
                    }
                    else
                    {
                        cell.textLabel!.text = ""
                    }
                    
                    return cell
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PlaceRouteCell
                
                cell.selectionStyle = .none
                
                if cell.cellButtonDelegate == nil {
                    cell.cellButtonDelegate = self
                }
                
                if cell.cellLabelDelegate == nil {
                    cell.cellLabelDelegate = self
                }
                
                cell.labelName.text = places[indexPath.row].name
                
                return cell
            }
        }
        else
        {
            if(routes.isEmpty)
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: emptyCellId, for: indexPath)
                
                cell.selectionStyle = .none
                cell.textLabel!.textAlignment = .left
                cell.textLabel!.textColor = .gray
                cell.textLabel!.numberOfLines = 0

                if(indexPath.row == 1)
                {
                    cell.textLabel!.text = "You haven't saved any routes.\nTap 'Plan ride' to plan a route."
                    cell.textLabel!.numberOfLines = 0
                    cell.textLabel!.adjustsFontSizeToFitWidth = true
                }
                else
                {
                    cell.textLabel!.text = ""
                }
                
                return cell
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PlaceRouteCell
                
                cell.selectionStyle = .none
                
                if cell.cellButtonDelegate == nil {
                    cell.cellButtonDelegate = self
                }
                
                if cell.cellLabelDelegate == nil {
                    cell.cellLabelDelegate = self
                }
                
                cell.labelName.text = places[indexPath.row].name
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(section == 0)
        {
            
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionHeaderId) as! TableSectionHeader
            view.buttonVisible = true
            view.title.text = "Favourite places"
            view.image.image = UIImage(systemName: "heart.circle.fill")
            view.addButton.isHidden = false
            
            if view.addPlaceButtonDelegate == nil {
                view.addPlaceButtonDelegate = self
            }
            
            return view
        }
        else if (section == 1)
        {
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionHeaderId) as! TableSectionHeader
            view.buttonVisible = false
            view.title.text = "Saved routes"
            view.image.image = UIImage(systemName: "bookmark.circle.fill")
            view.addButton.isHidden = true
            
            return view
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(places.isEmpty && !routes.isEmpty)
        {
            if (indexPath.section == 0)
            {
                return 40
            }
        }
        
        if(!places.isEmpty && routes.isEmpty)
        {
            if (indexPath.section == 1)
            {
                return 40
            }
        }
        
        if(places.isEmpty && routes.isEmpty)
        {
            return 40
        }
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionFooterId)
    }
    
    func cellLabelTapped(cell: PlaceRouteCell) {
        let place = places[cell.index]
        
        let rideController = RideController()
        rideController.modalPresentationStyle = .fullScreen
        rideController.currentPlaceCoordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        rideController.modalTransitionStyle = .crossDissolve
        navigationController?.presentDetail(rideController)
    }
    
    func cellTapped(cell: PlaceRouteCell) {
        
        let alertController = UIAlertController(title: cell.labelName.text, message: nil, preferredStyle: .actionSheet)
        
        let moveToTop: ActionHandler = { _ in self.moveToTop(index: self.tableView.indexPath(for: cell)!.row, section: self.tableView.indexPath(for: cell)!.section) }
        let renamePlaceRoute: ActionHandler = { [self] _ in self.showRenameAlert(index: self.tableView.indexPath(for: cell)!.row, section: tableView.indexPath(for: cell)!.section) }
        let deletePlaceRoute: ActionHandler = { [self] _ in self.deletePlaceRoute(index: self.tableView.indexPath(for: cell)!.row, section: tableView.indexPath(for: cell)!.section) }
        
        
        let actions: [(String, UIAlertAction.Style, ActionHandler?)] = [
            ("Move to top", .default, moveToTop),
            ("Rename", .default, renamePlaceRoute),
            ("Delete", .destructive, deletePlaceRoute),
            ("Cancel", .cancel, nil),
        ]
        
        actions
            .map({ payload in UIAlertAction(title: payload.0, style: payload.1, handler: payload.2) })
            .forEach(alertController.addAction(_:))
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showRenameAlert(index: Int, section: Int) {
        
        showInputDialog(title: "Rename",
                        subtitle: nil,
                        actionTitle: "Save",
                        cancelTitle: "Cancel",
                        inputPlaceholder: places[index].name,
                        inputKeyboardType: .default,
                        actionHandler: { (input:String?) in
            print("The new name is \(input ?? "")")
            self.renamePlaceRoute(index: index, section: section, newName: input ?? places[index].name)
        })
        
    }
    
    func moveToTop(index: Int, section: Int) {
        
        
        do {
            UserDefaults.standard.removeObject(forKey: "places")
            places.move(from: index, to: 0)
            let encodedData = try JSONEncoder().encode(places)
            let userDefaults = UserDefaults.standard
            userDefaults.set(encodedData, forKey: "places")
        } catch {
            // Failed to encode Contact to Data
        }
        
        
        tableView.reloadData()
    }
    
    func renamePlaceRoute(index: Int, section: Int, newName: String) {
      
        
        do {
            UserDefaults.standard.removeObject(forKey: "places")

            if places.safelyAccessElement(at: index) != nil{
                places[index].name = newName
            }

            let encodedData = try JSONEncoder().encode(places)
            let userDefaults = UserDefaults.standard
            userDefaults.set(encodedData, forKey: "places")
            tableView.reloadData()
        } catch {
            print("Failed to encode Contact to Data")
        }
        
    }
    
    
    func deletePlaceRoute(index: Int, section: Int) {
        if section == 0
        {
            places.remove(at: index)
        }
        
        if section == 1
        {
            routes.remove(at: index)
        }
        tableView.reloadSections([section], with: .automatic)

    }
    
    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Save",
                         cancelTitle:String? = "Cancel",
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension HomeController: ConnectionObserver {
    func bluetoothAvailable(_ available: Bool) {
        print("SensorViewController - Bluetooth available: \(available)")

        
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deviceConnected"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTableDevice"), object: nil)
        
    }

    func connected(to peripheral: PeripheralIdentifier) {
        print("SensorViewController - Connected to: \(peripheral.description)")

        sensor = peripheral
//        listen(to: heartRateCharacteristic)
//        listen(to: chirpCharacteristic)
//
//        tableView.reloadData()
        
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deviceConnected"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTableDevice"), object: nil)

        let content = UNMutableNotificationContent()
        content.title = "Bluejay Heart Sensor"
        content.body = "Connected."

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func disconnected(from peripheral: PeripheralIdentifier) {
        print("SensorViewController - Disconnected from: \(peripheral.description)")

        
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deviceConnected"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTableDevice"), object: nil)
        
        let content = UNMutableNotificationContent()
        content.title = "Bluejay Heart Sensor"
        content.body = "Disconnected."

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
