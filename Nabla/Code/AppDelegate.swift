import CommonUI
import Foundation
import Logbook
import Networking
import UIKit
import Utilities
import ForceUpdateFeature
import Toolbox
import Bluejay
import UserNotifications
import FirebaseCore

let bluejay = Bluejay()

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupLogging(for: AppEnvironment.current)
        log.info(AppEnvironment.current.appInfo)

        Appearance.setup()
        API.setup()
        CredentialsController.shared.resetOnNewInstallations()

        setupForceUpdate()
        
        requestPermissionForAlerts()
        
        setupBluejay(with: launchOptions)
        
        FirebaseApp.configure()

        return true
    }
    
    private func requestPermissionForAlerts() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("User notifications authorization granted")
            } else if let error = error {
                print("User notifications authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupBluejay(with launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        let backgroundRestoreConfig = BackgroundRestoreConfig(
            restoreIdentifier: BLECostants.peripheralRestoreIdentifier,
            backgroundRestorer: self,
            listenRestorer: self,
            launchOptions: launchOptions)
        
        let backgroundRestoreMode = BackgroundRestoreMode.enable(backgroundRestoreConfig)
        
        let options = StartOptions(enableBluetoothAlert: true, backgroundRestore: backgroundRestoreMode)
        
        bluejay.start(mode: .new(options))
    }

    // MARK: UISceneSession Lifecycle

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

// MARK: - Logging

extension AppDelegate {

    func setupLogging(for environment: AppEnvironment) {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .none
        dateformatter.timeStyle = .medium

        switch environment.buildConfig {
        case .debug:
            let sink = ConsoleLogSink(level: .min(.debug))

            sink.format = "> \(LogPlaceholder.category) \(LogPlaceholder.date): \(LogPlaceholder.messages)"
            sink.dateFormatter = dateformatter

            log.add(sink: sink)
        case .release:
            log.add(sink: OSLogSink(level: .min(.warning)))
        }
    }
}

// MARK: - Bluetooth setup

extension AppDelegate: BackgroundRestorer {
    func didRestoreConnection(to peripheral: PeripheralIdentifier) -> BackgroundRestoreCompletion {
        let content = UNMutableNotificationContent()
        content.title = "Bluejay Heart Sensor"
        content.body = "Did restore connection."

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)

        return .continue
    }

    func didFailToRestoreConnection(to peripheral: PeripheralIdentifier, error: Error) -> BackgroundRestoreCompletion {
        let content = UNMutableNotificationContent()
        content.title = "Bluejay Heart Sensor"
        content.body = "Did fail to restore connection."

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)

        return .continue
    }
}

extension AppDelegate: ListenRestorer {
    func didReceiveUnhandledListen(from peripheral: PeripheralIdentifier, on characteristic: CharacteristicIdentifier, with value: Data?) -> ListenRestoreAction {
        let content = UNMutableNotificationContent()
        content.title = "Bluejay Heart Sensor"
        content.body = "Did receive unhandled listen."

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)

        return .promiseRestoration
    }
}

// MARK: - Force Update

private extension AppDelegate {

    /// Sets up the `ForceUpdateController` and calls `checkForUpdate()`, if not in debug mode.
    func setupForceUpdate() {
        guard AppEnvironment.current.buildConfig != .debug else { return }
        
        Task {
            await ForceUpdateController.shared.checkForUpdate()
        }
    }
}
