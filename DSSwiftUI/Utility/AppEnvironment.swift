//
//  AppEnvironment.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 12/26/21.
//

import Foundation

final class AppEnvironment {
    
    static let shared: AppEnvironment = .init()
    private init() {}
    
    lazy var isTesting: Bool = {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil || ProcessInfo.processInfo.environment["UITesting"] == "YES"
    }()

    func resetTestApp() {
        guard isTesting else { return }
        UserDefaults.standard.removeAllAppSettings()
        KeychainManager.shared.clearAll()
    }
    
}

extension UserDefaults {
    
    func removeAllAppSettings() {
        guard let defaultsName = Bundle.main.bundleIdentifier else { return }
        removePersistentDomain(forName: defaultsName)
    }
    
}
