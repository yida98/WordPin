//
//  WordPinApp.swift
//  WordPin
//
//  Created by Yida Zhang on 7/7/23.
//

import SwiftUI

@main
struct WordPinApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
