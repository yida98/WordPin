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

    var displayName: String = "Placeholder"
}
