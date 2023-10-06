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
            Spacer(minLength: 0)
            if let leaderboard = viewModel.aggregatedLeaderboard, leaderboard.count != 0, let record = viewModel.record {
                Text(String(record))
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
                    ForEach(leaderboard.indices, id: \.self) { leaderboardIndex in
                        LeaderboardCell(submission: leaderboard[leaderboardIndex])
                    }
                }
                .background(.clear)
                .scrollContentBackground(.hidden)
                .refreshable {
                    do {
                        try await viewModel.updateLeaderboard()
                    } catch let error {
                        debugPrint(error.localizedDescription)
                    }
                }
            } else {
                VStack {
                    if viewModel.updatingLeaderboard {
                        ProgressView {
                            Text("Loading...")
                                .font(.monospaced(size: .caption1, emphasis: .bold))
                        }
                        .foregroundColor(.secondaryFont)
                        .frame(height: 100)
                    } else {
                        Button {
                            Task(priority: .background) {
                                do {
                                    try await viewModel.updateLeaderboard()
                                } catch let error {
                                    debugPrint(error.localizedDescription)
                                }
                            }
                        } label: {
                            VStack(spacing: 10) {
                                Image(systemName: "arrow.clockwise.circle")
                                Text("Nothing yet")
                                    .font(.monospaced(size: .caption1, emphasis: .bold))
                            }
                            .foregroundColor(.secondaryFont)
                        }
                        .frame(height: 100)
                    }
                }
            }
            Spacer(minLength: 0)
            // User information
            HStack {
                Text(viewModel.displayName)
                    .font(.monospaced(size: .caption1))
                    .foregroundColor(.jadeShadow)
                Spacer()
                Text(viewModel.personalRecord != nil ? String(viewModel.personalRecord!.groupCount) : "UNSOLVED")
                    .font(.monospaced(size: .caption1, emphasis: .bold))
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
                do {
                    try await viewModel.updateLeaderboard()
                } catch let error {
                    debugPrint(error.localizedDescription)
                }
            }
        }
    }
}
