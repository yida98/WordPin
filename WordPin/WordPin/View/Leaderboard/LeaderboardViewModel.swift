//
//  LeaderboardViewModel.swift
//  WordPin
//
//  Created by Yida Zhang on 9/29/23.
//

import Foundation

class LeaderboardViewModel: ObservableObject {
    @Published var leaderboard: [Submission]?
    @Published var record: Int?
    var word: String?
    var displayName: String

    init(word: String? = nil, displayName: String) {
        self.word = word
        self.displayName = displayName

        Task { [weak self] in
            try? await self?.updateLeaderboard()
        }
    }

    func updateLeaderboard() async throws {
        // Find minimum input (1 number)
        debugPrint("updating")
        let task = Task(priority: .background) { [weak self] in
            if let word = self?.word {
                let leaderboardSubmissions = try await URLTask.shared.getSubmissions(for: word)
                DispatchQueue.main.async { [weak self] in
                    self?.leaderboard = leaderboardSubmissions
                }
            } else {
                let dailyWord = try await URLTask.shared.getDailyWord()
                let leaderboardSubmissions = try await URLTask.shared.getSubmissions(for: dailyWord)
                DispatchQueue.main.async { [weak self] in
                    self?.leaderboard = leaderboardSubmissions
                    self?.word = dailyWord
                }
            }
        }

        let timeOutTask = Task {
            try await Task.sleep(nanoseconds: UInt64(4) * NSEC_PER_SEC)
            task.cancel()
            debugPrint("cancelled")
        }

        do {
            try await task.value
            timeOutTask.cancel()
        } catch let error {
            throw error
        }
        // All users and their solutions
//        let record =
        // All users that match the record and how many unique solutions they have
//        let users =
    }
}
