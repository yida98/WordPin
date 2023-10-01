//
//  LeaderboardViewModel.swift
//  WordPin
//
//  Created by Yida Zhang on 9/29/23.
//

import Foundation

class LeaderboardViewModel: ObservableObject {
    @Published var leaderboard: [Submission]?
    @Published var updatingLeaderboard: Bool = false
    @Published var record: Int?
    @Published var displayName: String
    @Published var personalRecord: Submission?
    var word: String?

    init(word: String? = nil) {
        self.word = word
        self.displayName = AppData.shared.displayName

        updatePersonalSubmission()
        Task { [weak self] in
            try? await self?.updateLeaderboard()
        }
    }

    func updateDisplayName() {
        self.displayName = AppData.shared.displayName
    }

    func updateLeaderboard() async throws {
        // Find minimum input (1 number)
        DispatchQueue.main.async { [weak self] in
            self?.updatingLeaderboard = true
        }

        let task = Task(priority: .background) { [weak self] in
            if let word = self?.word {
                let leaderboardSubmissions = try await URLTask.shared.getSubmissions(for: word)
                DispatchQueue.main.async { [weak self] in
                    self?.leaderboard = leaderboardSubmissions
                    self?.updatingLeaderboard = false
                }
            } else {
                let dailyWord = try await URLTask.shared.getDailyWord()
                let leaderboardSubmissions = try await URLTask.shared.getSubmissions(for: dailyWord)
                DispatchQueue.main.async { [weak self] in
                    self?.leaderboard = leaderboardSubmissions
                    self?.word = dailyWord
                    self?.updatingLeaderboard = false
                }
            }
        }

        let timeOutTask = Task {
            try await Task.sleep(nanoseconds: UInt64(4) * NSEC_PER_SEC)
            task.cancel()
            DispatchQueue.main.async { [weak self] in
                self?.updatingLeaderboard = false
            }
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

    func updatePersonalSubmission() {
        if let word = word, let submissions = PersistenceController.shared.fetchOne(word), let bestPersonalRecord = submissions.sorted(by: { $0.groupCount < $1.groupCount }).first {
            self.personalRecord = bestPersonalRecord
        }
    }
}
