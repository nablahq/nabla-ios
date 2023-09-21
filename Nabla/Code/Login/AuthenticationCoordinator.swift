//
//  AuthenticationCoordinator.swift
//  Nabla
//
//  Created by Jaksa Tomovic on 20.09.2023..
//  Copyright © 2023 canarin team. All rights reserved.
//

import Toolbox
import UIKit

public class AuthenticationCoordinator: NavigationCoordinator {
    
    // MARK: Interface
        
    public var onLogin: (() -> Void)?

    // MARK: - Init
        
    override public init(navigationController: UINavigationController) {
        super.init(navigationController: navigationController)
        navigationController.isModalInPresentation = true
        navigationController.modalPresentationStyle = .fullScreen
    }
    
    // MARK: Start
    
    override public func start() {
        let viewController = AuthenticationController.create()
        viewController.onLogin = onLogin
        
        push(viewController, animated: false)
    }
}
