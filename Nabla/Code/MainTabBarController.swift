//
//  MainTabBarController.swift
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .white
        
        UINavigationBar.appearance().prefersLargeTitles = true
        
        tabBar.tintColor = .black
        
        setupViewControllers()
    }
    
    func setupViewControllers() {
//        let layout = UICollectionViewFlowLayout()
//        let favoritesController = FavoritesController(collectionViewLayout: layout)
        viewControllers = [
            generateNavigationController(for: HomeController(), title: "Ride", image: UIImage(systemName: "arrowtriangle.down.circle")!),
//            generateNavigationController(for: JourneyController(), title: "Journeys", image: #imageLiteral(resourceName: "downloads")),
            generateNavigationController(for: SettingsController(), title: "Settings", image: UIImage(systemName: "gearshape")!)
        ]
    }
    
    // MARK:- Helper Functions
    
    fileprivate func generateNavigationController(for rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
//        navController.navigationBar.prefersLargeTitles = false
        rootViewController.navigationItem.title = title
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        return navController
    }
}
