//
//  PlayerAttempts.swift
//  WordPin
//
//  Created by Yida Zhang on 9/13/23.
//

import SwiftUI

struct PlayerAttempts: View {
    @EnvironmentObject var viewModel: ContentViewModel

    var body: some View {
        VStack {
            Text("3")
                .background(
                    Image(systemName: "crown.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.yellow.opacity(0.5))
                        .frame(width: 60)
                )
                .accessibilityLabel("World record")
            Text("Attempts")
            ForEach(0..<10, id: \.self) { index in
                LeaderboardCell(username: "idkuser1", uniqueEntries: index)
            }
            HStack {
                Text(viewModel.displayName)
                Spacer()
                Text("UNSOLVED")
            }
        }
    }
}

struct Leaderboard_Previews: PreviewProvider {
    static var previews: some View {
        PlayerAttempts()
    }
}
