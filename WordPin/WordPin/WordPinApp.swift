//
//  WordPinApp.swift
//  WordPin
//
//  Created by Yida Zhang on 7/7/23.
//

import SwiftUI

@main
struct WordPinApp: App {
    @UIApplicationDelegateAdaptor var applicationDelegate: AppData
    let persistenceController = PersistenceController.shared
    @StateObject var networkMonitor = NetworkMonitor()
    @StateObject var viewModel = ContentViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
