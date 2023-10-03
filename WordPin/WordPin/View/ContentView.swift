//
//  ContentView.swift
//  WordPin
//
//  Created by Yida Zhang on 7/7/23.
//

import SwiftUI
import CoreData
import UIKit

struct ContentView: View {
    @EnvironmentObject var viewModel: ContentViewModel
    @EnvironmentObject private var applicationDelegate: AppData

    @State private var usernameIsValid: Bool = true

    @State var showingGame: Bool = false

    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.jade)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
    }

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
            TabView {
                GameTab(viewModel: viewModel)
                    .padding(.vertical, 60)
                PlayerAttempts(word: viewModel.word, displayName: viewModel.displayName)
                    .padding(.vertical, 60)
                PlayerHistory()
                    .padding(.vertical, 60)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
        .background(Color.background)
    }
}
