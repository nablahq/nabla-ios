//
//  HomeCoordinator.swift
//  Nabla
//
//  Created by Jaksa Tomovic on 20.09.2023..
//  Copyright © 2023 canarin team. All rights reserved.
//

import UIKit
import Assets
import Networking
import Toolbox

public class HomeCoordinator: NavigationCoordinator {

    // MARK: Init

    public init(title: String, navigationController: UINavigationController = UINavigationController()) {
        super.init(navigationController: navigationController)

        navigationController.tabBarItem.title = title
        navigationController.tabBarItem.image = UIImage(systemName: "arrowtriangle.down.circle")
        navigationController.tabBarItem.selectedImage = UIImage(systemName: "arrowtriangle.down.circle")
        navigationController.navigationBar.prefersLargeTitles = true
    }

    // MARK: Start

    override public func start() {
        let viewController = HomeController()

        push(viewController, animated: false)
    }
}

