//
//  LeaderboardViewModel.swift
//  WordPin
//
//  Created by Yida Zhang on 9/29/23.
//

import Foundation

class LeaderboardViewModel: ObservableObject {
    @Published var aggregatedLeaderboard: [AggregatedLeaderboardSubmission]?
    @Published var updatingLeaderboard: Bool = false
    @Published var record: Int32?
    @Published var displayName: String
    @Published var personalRecord: Submission?
    var word: String?

    init(word: String? = nil) {
        self.word = word
        self.displayName = AppData.shared.displayName

        updatePersonalSubmission()
        Task { [weak self] in
            do {
                try await self?.updateLeaderboard()
            } catch let error {
                debugPrint(error.localizedDescription)
            }
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
                    self?.updateAggregatedLeaderboardData(from: leaderboardSubmissions)
                    self?.updatingLeaderboard = false
                }
            } else {
                let dailyWord = try await URLTask.shared.getDailyWord()
                let leaderboardSubmissions = try await URLTask.shared.getSubmissions(for: dailyWord)
                DispatchQueue.main.async { [weak self] in
                    self?.updateAggregatedLeaderboardData(from: leaderboardSubmissions)
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

    func updateAggregatedLeaderboardData(from submissions: [Submission]) {
        var aggregatedIdMap = [String: Int]()
        var idToDisplayNameMap = [String: String]()

        for submission in submissions {
            if (record == nil) || record != submission.groupCount {
                record = submission.groupCount
            }
            if let userId = submission.userId {
                idToDisplayNameMap[userId] = submission.displayName ?? "Unknown"
                if let value = aggregatedIdMap[userId] {
                    aggregatedIdMap[userId] = value + 1
                } else {
                    aggregatedIdMap[userId] = 1
                }
            }
        }



        var result = [AggregatedLeaderboardSubmission]()
        for (userId, value) in aggregatedIdMap {
            result.append(AggregatedLeaderboardSubmission(displayName: idToDisplayNameMap[userId] ?? "Unknown", userId: userId, submissions: value))
        }

        self.aggregatedLeaderboard = result
    }
}

struct AggregatedLeaderboardSubmission {
    var displayName: String
    var userId: String
    var submissions: Int
}
