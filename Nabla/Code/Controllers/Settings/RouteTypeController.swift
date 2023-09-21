//
//  RouteTypeController.swift
//  ble-tbt-navigation-ios
//
//  Created by Jaksa Tomovic on 28.08.2023..
//

import UIKit
import ALRadioButtons

class RouteTypeController: UIViewController {
    
    lazy var radioGroup = ALRadioGroup(items: [
        .init(title: "🏍️ Motorcycle"),
        .init(title: "🚲 Bicycle")
    ], style: .standard)
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Route type"
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
    
        view.addSubview(radioGroup)
        radioGroup.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: view.safeAreaInsets.top + (navigationController?.navigationBar.frame.size.height)! + 20, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: 0, heightConstant: 100)
        if UserDefaults.standard.bool(forKey: "is_motorcycle_route_type")
        {
            radioGroup.selectedIndex = 0
        }
        else
        {
            radioGroup.selectedIndex = 1
        }
        radioGroup.addTarget(self, action: #selector(radioGroupSelected(_:)), for: .valueChanged)
        
        radioGroup.separatorColor = .clear
    }
    
    @objc private func radioGroupSelected(_ sender: ALRadioGroup) {
        if sender.selectedIndex == 0
        {
            UserDefaults.standard.set(true, forKey: "is_motorcycle_route_type")
        }
        else
        {
            UserDefaults.standard.set(false, forKey: "is_motorcycle_route_type")
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTablePreferences"), object: nil)
     }
}
