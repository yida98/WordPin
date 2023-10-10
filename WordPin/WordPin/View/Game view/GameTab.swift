//
//  GameTab.swift
//  WordPin
//
//  Created by Yida Zhang on 9/13/23.
//

import SwiftUI

struct GameTab: View {
    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        VStack {
            if let currentGame = viewModel.currentGame {
                HStack {
                    Spacer()
                    Button {
                        viewModel.restartGame()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle")
                            Text("restart")
                                .font(.monospaced(size: .caption1, emphasis: .bold))
                        }
                        .foregroundColor(.jade)
                    }
                    .padding(5)
                    .padding(.horizontal, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.jade.opacity(0.2))
                    )
                }
                .padding(.horizontal, 50)
                Spacer(minLength: 0)
                GameView(viewModel: currentGame)
            } else {
                Spacer(minLength: 0)
                VStack {
                    if viewModel.loadingGame {
                        ProgressView {
                            Text("Loading...")
                                .font(.monospaced(size: .caption1, emphasis: .bold))
                        }
                        .foregroundColor(.secondaryFont)
                        .frame(height: 100)
                    } else {
                        Button {
                            viewModel.attachGameSession()
                        } label: {
                            VStack(spacing: 10) {
                                Image(systemName: "arrow.clockwise.circle")
                                Text("Server error")
                                    .font(.monospaced(size: .caption1, emphasis: .bold))
                            }
                            .foregroundColor(.secondaryFont)
                        }
                        .frame(height: 100)
                    }
                }
            }
            Spacer(minLength: 0)
        }
    }
}
