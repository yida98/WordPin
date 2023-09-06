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

    @State private var usernameIsValid: Bool = true

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person.crop.circle")
                    .foregroundColor(usernameIsValid ? .primaryFont : .tertiaryFont)
                TextField("", text: $viewModel.displayName)
                    .font(.primary(size: .title2, emphasis: .bold))
                    .foregroundColor(.primaryFont)
                    .multilineTextAlignment(.center)
                    .autocorrectionDisabled(true)
                    .onSubmit {
                        if viewModel.displayName.isEmpty {
                            viewModel.displayName = AppData.generateUsername()
                        }
                        applicationDelegate.updateDisplayName(viewModel.displayName)
                    }
                    .onChange(of: viewModel.displayName, perform: { newValue in
                        usernameIsValid = !newValue.isEmpty
                        if newValue.count > 8 {
                            viewModel.displayName = String(newValue.prefix(6))
                        }
                    })
                    .fixedSize()
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
