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
            HStack {
                Spacer()
                Button {
                    viewModel.restartGame()
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise.circle")
                        Text("Restart")
                            .font(.secondaryFont())
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
            .padding(50)
            Spacer()
            Group {
                if let currentGame = viewModel.currentGame {
                    GameView(viewModel: currentGame)
                } else {
                    ProgressView()
                }
            }
            .frame(height: Constant.screenBounds.height * 0.75)
        }
        .background(Color.background)
    }
}
