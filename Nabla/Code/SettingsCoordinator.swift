//
//  SettingsCoordinator.swift
//  Nabla
//
//  Created by Jaksa Tomovic on 20.09.2023..
//  Copyright © 2023 canarin team. All rights reserved.
//

import UIKit
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
        viewController.navigationItem.title = "Settings"//Strings.exampleTitle
        viewController.navigationItem.largeTitleDisplayMode = .never

        push(viewController, animated: false)
    }
}
