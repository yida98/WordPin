//
//  ContentView.swift
//  WordPin
//
//  Created by Yida Zhang on 7/7/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    @EnvironmentObject private var applicationDelegate: AppData
    
    var body: some View {
        VStack {
            Button(applicationDelegate.displayName) {
                // TODO: Do something

            }
            if let currentGame = viewModel.currentGame {
                GameView(viewModel: currentGame)
            } else {
                ProgressView()
            }
            HStack {
                Spacer(minLength: 0)
                Button("Leaderboards") {
                    // TODO: Leaderboards
                }
                Spacer(minLength: 0)
                Button("Statistics") {
                    // TODO: Leaderboards
                }
                Spacer(minLength: 0)
            }
        }
        .background(Color.background)
    }
}
