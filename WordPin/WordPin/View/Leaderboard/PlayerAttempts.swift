//
//  PlayerAttempts.swift
//  WordPin
//
//  Created by Yida Zhang on 9/13/23.
//

import SwiftUI

struct PlayerAttempts: View {
    @StateObject var viewModel: LeaderboardViewModel

    init(word: String?, displayName: String) {
        self._viewModel = StateObject(wrappedValue: LeaderboardViewModel(word: word))
    }

    var body: some View {
        VStack {
            Text("Leaderboard")
                .font(.primary(size: .title1, emphasis: .bold))
                .foregroundColor(.primaryFont)
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
                            LeaderboardCell(submission: leaderboard[leaderboardIndex])
                        }
                    }
                    .background(.clear)
                    .scrollContentBackground(.hidden)
                    .refreshable {
                        try? await viewModel.updateLeaderboard()
                    }
                } else {
                    VStack {
                        if viewModel.updatingLeaderboard {
                            ProgressView {
                                Text("Loading...")
                                    .font(.secondaryFont(size: .headline))
                            }
                            .foregroundColor(.secondaryFont)
                            .frame(height: 100)
                        } else {
                            Button {
                                Task(priority: .background) {
                                    try await viewModel.updateLeaderboard()
                                }
                            } label: {
                                VStack(spacing: 10) {
                                    Image(systemName: "arrow.clockwise.circle")
                                    Text("Nothing yet")
                                        .font(.secondaryFont(size: .headline))
                                }
                                .foregroundColor(.secondaryFont)
                            }
                            .frame(height: 100)
                        }
                    }
                }
            }
            .frame(height: Constant.screenBounds.height * 0.5)
            HStack {
                Text(viewModel.displayName)
                    .font(.secondaryFont())
                    .foregroundColor(.jadeShadow)
                Spacer()
                Text(viewModel.personalRecord != nil ? String(viewModel.personalRecord!.groupCount) : "UNSOLVED")
                    .font(.secondaryFont())
                    .foregroundColor(viewModel.personalRecord != nil ? .success : .failure)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.white)
                    .shadow(color: .primaryFont.opacity(0.2), radius: 6, x: 0, y: 4)
            )
        }
        .padding(.horizontal, 50)
        .onAppear {
            viewModel.updateDisplayName()
            viewModel.updatePersonalSubmission()
            Task {
                try? await viewModel.updateLeaderboard()
            }
        }
    }
}
