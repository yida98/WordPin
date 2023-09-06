//
//  AppData.swift
//  WordPin
//
//  Created by Yida Zhang on 9/4/23.
//

import Foundation
import UIKit

class AppData: NSObject, UIApplicationDelegate, ObservableObject {
    static let shared = AppData()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }

    static let userID: String = {
        let userDefaults = UserDefaults.standard
        let userIDKey = "userID"
        if let id = userDefaults.string(forKey: userIDKey) {
            return id
        }
        let newID = UIDevice.current.identifierForVendor ?? UUID()
        userDefaults.set(newID.uuidString, forKey: userIDKey)
        return newID.uuidString
    }()

    var displayName: String {
        let userDefaults = UserDefaults.standard
        let displayNameKey = "displayName"
        if let displayName = userDefaults.string(forKey: displayNameKey) {
            return displayName
        }
        let newDisplayName = AppData.generateUsername()
        userDefaults.set(newDisplayName, forKey: displayNameKey)
        return newDisplayName
    }

    func updateDisplayName(_ name: String) {
        var validName = name
        if validName.isEmpty {
            validName = AppData.generateUsername()
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(validName, forKey: "displayName")
        self.objectWillChange.send()
    }

    static func generateUsername() -> String {
        "User\(Int.random(in: 1000...9999))"
    }
}
