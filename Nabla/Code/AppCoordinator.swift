import AuthFeature
import Combine
import ForceUpdateFeature
import MainFeature
import Networking
import Toolbox
import UIKit
import Utilities

public class MainTabCoordinator: TabBarCoordinator {

    // MARK: - Properties

    private lazy var firstCoordinator = HomeCoordinator(title: Constants.mainTabFirst)
    private lazy var secondCoordinator = SettingsCoordinator(title: Constants.mainTabSecond)

    // MARK: - Tabs

    private enum Tab: Int, CaseIterable {
        case first = 0
        case second
    }

    private func setupTabs() {
        addChild(firstCoordinator)
        addChild(secondCoordinator)

        firstCoordinator.start()
        secondCoordinator.start()

        tabBarController.viewControllers = [
            firstCoordinator.rootViewController,
            secondCoordinator.rootViewController,
        ]

        tabBarController.selectedIndex = 0
    }

    // MARK: - Coordinator Start

    override public func start() {
        setupTabs()
        
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.backgroundColor = .white
        tabBarController.tabBar.tintColor = .black
    }

    public func reset(animated: Bool) {
        childCoordinators.forEach {
            ($0 as? NavigationCoordinator)?.popToRoot(animated: animated)
        }
        tabBarController.selectedIndex = 0
    }

    // MARK: - Helpers

    private func setTab(_ tab: Tab) {
        tabBarController.selectedIndex = tab.rawValue
    }
}

class AppCoordinator: Coordinator {

    // MARK: Init

    override private init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    // MARK: Properties

    static let shared = AppCoordinator(rootViewController: .init())

    private(set) var window: UIWindow!
    private var cancellables = Set<AnyCancellable>()
    private let mainCoordinator = MainTabCoordinator(tabBarController: .init())
    private var forceUpdateWindow: ForceUpdateWindow?

    // MARK: Start

    func start(window: UIWindow) {
        self.window = window

        mainCoordinator.start()
        addChild(mainCoordinator)

        window.rootViewController = mainCoordinator.rootViewController
        window.makeKeyAndVisible()

        printRootDebugStructure()

        CredentialsController.shared.currentCredentialsDidChange
            .sink { [weak self] credentials in
                if credentials == nil {
                    self?.presentLogin(animated: true)
                }
            }
            .store(in: &cancellables)

        if CredentialsController.shared.currentCredentials == nil {
            presentLogin(animated: false)
        }

        if AppEnvironment.current.buildConfig != .debug {
            Task {
                for await url in ForceUpdateController.shared.onForceUpdateNeededAsyncSequence {
                    self.presentForceUpdate(url: url)
                }
            }
        }
    }

    // MARK: Present

    private func presentLogin(animated: Bool) {
        let coordinator = AuthenticationCoordinator(navigationController: .init())

        coordinator.onLogin = { [weak self] in
            self?.reset(animated: true)
        }

        coordinator.start()

        addChild(coordinator)
        window.topViewController()?.present(coordinator.rootViewController, animated: animated, completion: nil)
    }

    private func presentForceUpdate(url: URL?) {
        guard forceUpdateWindow == nil else { return }
        forceUpdateWindow = ForceUpdateWindow(appStoreURL: url)
        forceUpdateWindow?.start()
    }

    // MARK: Helpers

    func reset(animated: Bool) {
        childCoordinators
            .filter { $0 !== mainCoordinator }
            .forEach { removeChild($0) }

        mainCoordinator.reset(animated: animated)

        printRootDebugStructure()
    }
}
