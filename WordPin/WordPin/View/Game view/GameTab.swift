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
                GameView(viewModel: currentGame)
            } else {
                ProgressView()
            }
        }
        .background(Color.background)
    }
}
