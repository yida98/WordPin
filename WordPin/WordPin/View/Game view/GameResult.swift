//
//  GameResult.swift
//  WordPin
//
//  Created by Yida Zhang on 8/21/23.
//

import SwiftUI

struct GameResult: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack {
            HStack {
                Text("Success!")
                    .font(.primary(size: .headline, emphasis: .bold))
                    .foregroundColor(.success)
            }
        }
    }
}
