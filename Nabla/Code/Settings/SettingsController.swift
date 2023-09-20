//
//  SettingsController.swift
//  ble-tbt-navigation-ios
//
//  Created by Jaksa Tomovic on 21.08.2023..
//

import UIKit
import MapboxMaps
import Toast

import Assets
import Networking
import Toolbox

public class SettingsCoordinator: NavigationCoordinator {

    // MARK: Init

    public init(title: String, navigationController: UINavigationController = UINavigationController()) {
        super.init(navigationController: navigationController)

        navigationController.tabBarItem.title = title
        navigationController.tabBarItem.image = UIImage(systemName: "gearshape")
        navigationController.tabBarItem.selectedImage = UIImage(systemName: "gearshape")
        navigationController.navigationBar.prefersLargeTitles = true
    }

    // MARK: Start

    override public func start() {
        let viewController = SettingsController()

        push(viewController, animated: false)
    }
}

// swiftlint:disable all
class SettingsController: UIViewController, UITableViewDelegate {
    
    fileprivate let cellId = "cellId"
    fileprivate let sectionHeaderId = "sectionHeader"
        
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .white
        tv.tintColor = .black
        tv.separatorStyle = .none
        tv.sectionHeaderTopPadding = 10
        return tv
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.fillSuperview()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        tableView.register(SettingsCell.self, forCellReuseIdentifier: cellId)
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: sectionHeaderId)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTablePreferences), name: NSNotification.Name(rawValue: "reloadTablePreferences"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableDevice), name: NSNotification.Name(rawValue: "reloadTableDevice"), object: nil)
    }
    
    @objc func reloadTablePreferences(notification: NSNotification){
        tableView.reloadSections([1], with: .automatic)
    }
    
    @objc func reloadTableDevice(notification: NSNotification){
        tableView.reloadSections([0], with: .automatic)
    }
}

extension SettingsController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0)
        {
            return "Nabla device"
        }
        else if (section == 1)
        {
            return "Preferences"
        }
        else if (section == 2)
        {
            return "User"
        }
        else if (section == 3)
        {
            return "Help"
        }
        else
        {
            return "Version 1.0.0"
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionHeaderId)!
        view.tintColor = UIColor(red: 242/255, green: 241/255, blue: 233/255, alpha: 1)
        view.textLabel?.textColor = .black
        view.textLabel?.font = UIFont.systemFont(ofSize: 14,weight: .light)

        if (section == 4)
        {
            view.textLabel?.textAlignment = .center
            
        }
        else{
            view.textLabel?.textAlignment = .left
        }
        
        return view
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0)
        {
            if bluejay.isConnected
            {
                return 4
            }
            else
            {
                return 2
            }
        }
        else if (section == 1)
        {
            return 4
        }
        else if (section == 2)
        {
            return 2
        }
        else if (section == 3)
        {
            return 3
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SettingsCell
        
        if cell.cellButtonDelegate == nil {
            cell.cellButtonDelegate = self
        }
        
        cell.selectionStyle = .none
        
        if(indexPath.section == 0)
        {
            if bluejay.isConnected
            {
                if(indexPath.row == 0)
                {
                    cell.labelName.text = "Nabla name"
                    cell.labelSelectedOption.text = "Nabla \(UserDefaults.standard.string(forKey: "nabla_device_name") ?? "unknown")"
                    cell.id = "nabla_name"
                    cell.labelSelectedOption.textColor = .darkGray
                    cell.labelName.textColor = .darkGray
                }
                else if(indexPath.row == 1)
                {
                    cell.labelName.text = "Nabla status"
                    cell.labelSelectedOption.text = "\(bluejay.isConnected == true ? "Connected" : "")"
                    cell.id = "nabla_status"
                    cell.labelSelectedOption.textColor = .darkGray
                    cell.labelName.textColor = .darkGray
                }
                else if(indexPath.row == 2)
                {
                    cell.labelName.text = "Firmware version"
                    cell.labelSelectedOption.text = "\(UserDefaults.standard.string(forKey: "nabla_firmware_version") ?? "0.0.0")"
                    cell.labelSelectedOption.textColor = .darkGray
                    cell.id = "firmware_version"
                    cell.labelName.textColor = .darkGray
                }
                else if(indexPath.row == 3)
                {
                    cell.labelName.text = "Unpair this Nabla"
                    cell.labelSelectedOption.text = ""
                    cell.labelSelectedOption.textColor = .darkGray
                    cell.id = "unpair_nabla"
                    cell.labelName.textColor = .darkGray
                }
            }
            else
            {
                if(indexPath.row == 0)
                {
                    cell.labelName.text = "Connect a Nabla device"
                    cell.labelSelectedOption.text = "Connect"
                    cell.id = "connect_nabla"
                    cell.labelSelectedOption.textColor = .darkGray
                    cell.labelName.textColor = .darkGray

                }
                else if(indexPath.row == 1)
                {
                    cell.labelName.text = "Buy a Nabla device"
                    cell.labelSelectedOption.text = "Shop online"
                    cell.labelSelectedOption.textColor = .systemBlue
                    cell.id = "buy_nabla"
                    cell.labelName.textColor = .darkGray
                }
            }
        }
        else if(indexPath.section == 1)
        {
            if(indexPath.row == 0)
            {
                cell.labelName.text = "Route type"
                cell.id = "route_type"
                cell.labelSelectedOption.textColor = .darkGray
                cell.labelName.textColor = .darkGray
                if  UserDefaults.standard.bool(forKey: "is_motorcycle_route_type") {
                    cell.labelSelectedOption.text = "Motorcycle"
                } else {
                    cell.labelSelectedOption.text = "Bicycle"
                }
            }
//            else if(indexPath.row == 1)
//            {
//                cell.labelName.text = "Route options"
//                cell.id = "route_options"
//                cell.labelSelectedOption.text = ""
//                cell.labelSelectedOption.textColor = .darkGray
//                cell.labelName.textColor = .darkGray
//            }
            else if(indexPath.row == 1)
            {
                cell.id = "distance_unit"
                cell.labelName.text = "Measurement System"
                cell.labelSelectedOption.textColor = .darkGray
                cell.labelName.textColor = .darkGray
                if UserDefaults.standard.bool(forKey: "is_metric_measurement_system") {
                    cell.labelSelectedOption.text = "Metric"
                } else {
                    cell.labelSelectedOption.text = "Imperial"
                }
            }
            else if(indexPath.row == 2)
            {
                cell.id = "notification"
                cell.labelName.text = "Notification settings"
                cell.labelSelectedOption.text = ""
                cell.labelSelectedOption.textColor = .darkGray
                cell.labelName.textColor = .darkGray
            }
            else if(indexPath.row == 3)
            {
                cell.id = "email"
                cell.labelName.text = "Email preferences"
                cell.labelSelectedOption.text = "View online"
                cell.labelSelectedOption.textColor = .systemBlue
                cell.labelName.textColor = .darkGray
            }
        }
        else if(indexPath.section == 2)
        {
            if(indexPath.row == 0)
            {
                cell.id = "sign_out"
                cell.labelName.text = "User"
                cell.labelName.textColor = .darkGray
                cell.labelSelectedOption.text = "Sign out"
                cell.labelSelectedOption.textColor = .darkGray
                cell.actionButton.tintColor = .darkGray
                cell.labelSelectedOption.text = ""
            }
            else if(indexPath.row == 1)
            {
                cell.id = "delete_user_data"
                cell.labelName.text = "Delete your data"
                cell.labelName.textColor = .red
                cell.actionButton.tintColor = .red
                cell.labelSelectedOption.text = ""
            }
        }
        else if(indexPath.section == 3)
        {
            if(indexPath.row == 0)
            {
                cell.id = "support"
                cell.labelName.text = "Support"
                cell.labelSelectedOption.text = "View online"
                cell.labelSelectedOption.textColor = .systemBlue
                cell.labelName.textColor = .darkGray
            }
            else if(indexPath.row == 1)
            {
                cell.id = "privacy_policy"
                cell.labelName.text = "Privacy policy"
                cell.labelSelectedOption.text = "View online"
                cell.labelSelectedOption.textColor = .systemBlue
                cell.labelName.textColor = .darkGray
            }
            else if(indexPath.row == 2)
            {
                cell.id = "copy_support_info"
                cell.labelName.text = "Copy support info"
                cell.labelSelectedOption.text = ""
                cell.labelSelectedOption.textColor = .darkGray
                cell.labelName.textColor = .darkGray
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension SettingsController: SettingsCellDelegate {
    func cellTapped(cell: SettingsCell) {
        
        if(cell.id == "connect_nabla")
        {
            let ble = BLEController()
            ble.modalPresentationStyle = .fullScreen
            navigationController?.present(ble, animated: true, completion: nil)
        }
        else if(cell.id == "buy_nabla")
        {
            if let url = URL(string: "https://www.hackingwithswift.com") {
                UIApplication.shared.open(url)
            }
        }
        else if(cell.id == "unpair_nabla")
        {
            if let appSettings = URL(string: "prefs:root=General&path=Bluetooth") {
                if UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings)
                }
            }
        }
        else if(cell.id == "route_type")
        {
            self.navigationController?.pushViewController(RouteTypeController(), animated: true)
        }
//        else if(cell.id == "route_options")
//        {
//            self.navigationController?.pushViewController(RouteOptionsController(), animated: true)
//        }
        else if(cell.id == "distance_unit")
        {
            self.navigationController?.pushViewController(MeasurementSystemController(), animated: true)
        }
        else if(cell.id == "notification")
        {
            if let bundleIdentifier = Bundle.main.bundleIdentifier, let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
                if UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings)
                }
            }
        }
        else if(cell.id == "email")
        {
            if let url = URL(string: "https://www.hackingwithswift.com") {
                UIApplication.shared.open(url)
            }
        }
        else if(cell.id == "sign_out")
        {
            let alert = UIAlertController(
                title: "Are you sure you want to sign out?",
                message: nil,
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (test) -> Void in
                CredentialsController.shared.currentCredentials = nil
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            self.present( alert, animated: true, completion: nil)
        }
        else if(cell.id == "delete_user_data")
        {
            let alert = UIAlertController(
                title: "Delete your data?",
                message: nil,
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (test) -> Void in
                UserDefaults.resetDefaults()
                UserDefaults.standard.synchronize()
                places.removeAll(keepingCapacity: false)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPlaces"), object: nil)
                if let tabBarController = self.tabBarController {
                    tabBarController.selectedIndex = 0
                }
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            self.present( alert, animated: true, completion: nil)
        }
        else if(cell.id == "support")
        {
            if let url = URL(string: "https://www.hackingwithswift.com") {
                UIApplication.shared.open(url)
            }
        }
        else if(cell.id == "privacy_policy")
        {
            if let url = URL(string: "https://www.hackingwithswift.com") {
                UIApplication.shared.open(url)
            }
        }
        else if(cell.id == "copy_support_info")
        {
            let pasteboard = UIPasteboard.general
            pasteboard.string = "Hello, world!"
            let toast = Toast.text("Copied to clipboard")
            toast.show(haptic: .success, after: 0)
        }
    }
}
//swiftlint:enable all
