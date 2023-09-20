//
//  Constants.swift
//  ble-tbt-navigation-ios
//
//  Created by Jaksa Tomovic on 19.08.2023..
//

import Foundation
import Assets

enum BLECostants {
    static let uuidService = "25AE1441-05D3-4C5B-8281-93D4E07420CF"
    static let uuidCharForRead = "25AE1442-05D3-4C5B-8281-93D4E07420CF"
    static let uuidCharForWrite = "25AE1443-05D3-4C5B-8281-93D4E07420CF"
    static let uuidCharForIndicate = "25AE1444-05D3-4C5B-8281-93D4E07420CF"
    
    static let centralRestoreIdentifier = "io.github.jaksatomovic.CentralManager"
    static let peripheralRestoreIdentifier = "io.github.jaksatomovic.PeripheralManager"
}

enum Constants {
    public static let mainTabFirst = Constants.tr("Localizable", "ride_tab", fallback: "Ride")
    public static let mainTabSecond = Constants.tr("Localizable", "settings_tab", fallback: "Settings")
}

// MARK: - Implementation Details

extension Constants {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
