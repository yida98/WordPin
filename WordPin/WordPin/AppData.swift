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
//        PersistenceController.shared.nuke()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        debugPrint("TERMINATING")
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

    func saveSession(_ gameSession: GameViewModel?) throws {
        let userDefaults = UserDefaults.standard
        let gameSessionKey = "gameSession"
        do {
            let encodedSession = try JSONEncoder().encode(gameSession)
            userDefaults.set(encodedSession, forKey: gameSessionKey)
            self.objectWillChange.send()
        } catch let error {
            throw error
        }
    }

    func removeSession() throws {
        do {
            try saveSession(nil)
        } catch let error {
            throw error
        }
    }

    func fetchExistingSession() throws -> GameViewModel? {
        let userDefaults = UserDefaults.standard
        let gameSessionKey = "gameSession"

        guard let currentGameSessionData = userDefaults.data(forKey: gameSessionKey) else { return nil }
        do {
            let decoder = JSONDecoder()
            let currentGameSession = try decoder.decode(GameViewModel.self, from: currentGameSessionData)
            return currentGameSession
        } catch let error {
            throw error
        }
    }
}
