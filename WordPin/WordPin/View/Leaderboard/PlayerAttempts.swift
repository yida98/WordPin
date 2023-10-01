//
//  PlayerAttempts.swift
//  WordPin
//
//  Created by Yida Zhang on 9/13/23.
//

import SwiftUI

struct PlayerAttempts: View {
    @StateObject var viewModel: LeaderboardViewModel
    @State var fetching: Bool = true

    init(word: String?, displayName: String) {
        self._viewModel = StateObject(wrappedValue: LeaderboardViewModel(word: word, displayName: displayName))
    }

    var body: some View {
        VStack {
            Group {
                if let leaderboard = viewModel.leaderboard, leaderboard.count != 0 {
                    Text(String(leaderboard.first!.groupCount))
                        .background(
                            Image(systemName: "crown.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.yellow.opacity(0.5))
                                .frame(width: 60)
                        )
                        .accessibilityLabel("World record")
                    Text("Attempts")
                    List {
                        Text("item")
                        ForEach(leaderboard.indices, id: \.self) { leaderboardIndex in
                            let username = leaderboard[leaderboardIndex].displayName ?? "unknown"
                            LeaderboardCell(username: username, uniqueEntries: leaderboardIndex)
                        }
                    }
                    .background(.clear)
                    .scrollContentBackground(.hidden)
                    .refreshable {
                        try? await viewModel.updateLeaderboard()
                    }
                } else {
                    VStack {
                        Spacer()
                        if fetching {
                            ProgressView {
                                Text("Fetching leaderboard...")
                            }
                            .onAppear {
                                Task(priority: .background) {
                                    try? await Task.sleep(nanoseconds: UInt64(4) * NSEC_PER_SEC)
                                    await MainActor.run {
                                        fetching = false
                                    }
                                }
                            }
                            .frame(height: 100)
                        } else {
                            Button {
                                fetching = true
                                Task(priority: .background) {
                                    try await viewModel.updateLeaderboard()
                                }
                            } label: {
                                VStack(spacing: 10) {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .foregroundColor(.gray)
                                    Text("Retry")
                                        .foregroundColor(.gray)
                                }
                            }
                            .frame(height: 100)
                        }
                    }
                }
            }
            .frame(height: Constant.screenBounds.height * 0.5)
            HStack {
                Text(viewModel.displayName)
                Spacer()
                Text("UNSOLVED")
            }
        }
    }
}
