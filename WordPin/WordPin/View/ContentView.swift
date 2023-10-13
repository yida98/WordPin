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

    @State private var selection: Int = 0
    @State private var currentPosition: CGPoint = .zero
    @State private var currentSize: CGSize = .zero
    @State private var tabsShowing: Bool = false

    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)

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
            TabView(selection: $selection) {
                GameTab(viewModel: viewModel)
                    .padding(.vertical, 50)
                    .tag(0)
                PlayerAttempts(word: viewModel.word, displayName: viewModel.displayName)
                    .padding(.vertical, 50)
                    .tag(1)
                PlayerHistory()
                    .padding(.vertical, 50)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            HStack {
                Spacer(minLength: 0)
                Button {
                    lightGenerator.impactOccurred()
                    selection = 0
                } label: {
                    Image(systemName: "gamecontroller")
                }
                .buttonStyle(FloatingTabButton())
                .background(floatingBackground(0))
                Spacer(minLength: 0)
                Button {
                    lightGenerator.impactOccurred()
                    selection = 1
                } label: {
                    Image(systemName: "globe.americas.fill")
                }
                .buttonStyle(FloatingTabButton())
                .background(floatingBackground(1))
                Spacer(minLength: 0)
                Button {
                    lightGenerator.impactOccurred()
                    selection = 2
                } label: {
                    Image(systemName: "person.text.rectangle")
                }
                .buttonStyle(FloatingTabButton())
                .background(floatingBackground(2))
                Spacer(minLength: 0)
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.jade.opacity(0.2))
                    .frame(width: currentSize.width + 14, height: currentSize.height + 14)
                    .position(currentPosition)
                    .animation(tabsShowing ? .easeOut(duration: 0.2) : .none, value: currentSize)
                    .animation(tabsShowing ? .easeOut(duration: 0.2) : .none, value: currentPosition)
                    .opacity(tabsShowing ? 1 : 0)
            )
            .coordinateSpace(name: "Tabs")
            .scenePadding(.minimum, edges: .bottom)
        }
        .background(Color.background)
        .onChange(of: currentSize) { newValue in
            if newValue != .zero {
                tabsShowing = true
            }
        }
    }

    private func floatingBackground(_ tabNumber: Int) -> some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear {
                    if selection == tabNumber {
                        updatingFloater(with: proxy)
                    }
                }
                .onChange(of: selection) { newValue in
                    if newValue == tabNumber {
                        updatingFloater(with: proxy)
                    }
                }
        }
    }

    private func updatingFloater(with proxy: GeometryProxy) {
        currentPosition = CGPoint(x: proxy.frame(in: .named("Tabs")).midX,
                                  y: proxy.frame(in: .named("Tabs")).midY)
        currentSize = proxy.size
    }
}

struct FloatingTabButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.jade)
    }
}
