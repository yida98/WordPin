//
//  ContentViewModel.swift
//  WordPin
//
//  Created by Yida Zhang on 9/5/23.
//

import Foundation
import Combine

class ContentViewModel: ObservableObject {
    @Published var currentGame: GameViewModel?
    @Published var displayName: String
    private var localSubmissionsSubscriber = Set<AnyCancellable>()

    init() {
        self.displayName = AppData.shared.displayName
        Task { [weak self] in
            await self?.makeNewGame()
        }
    }

    func makeNewGame(_ word: String? = "nil") async -> GameViewModel? {
        if let word = word {
            await MainActor.run { [weak self] in
                self?.currentGame = GameViewModel(word)
            }
        } else {
            if let newWord = try? await URLTask.shared.getNewWord().first {
                await MainActor.run { [weak self] in
                    self?.currentGame = GameViewModel(newWord)
                }
            }
        }
        return self.currentGame
    }

    func finishedGame() {
//        // TODO: Take the game stats and upload it
//        if let currentGame = currentGame, currentGame.gameFinished {
//            if let submission = PersistenceController.shared.save(word: currentGame.word, group: currentGame.words) as? Submission {
//                // TODO: UserID not created
////                URLTask.shared.postSubmission(submission)
//            }
//        }
//        // TODO: Continue the game until new game
//        self.currentGame = nil
    }

    func leaderboard() async -> [String] {
        // Find minimum input (1 number)
        let results = await URLTask.shared.getSubmissions(for: "dailyword")
        // All users and their solutions
//        let record =
        // All users that match the record and how many unique solutions they have
//        let users =
        return []
    }
}

struct LeaderboardUser {
    var userID: String
    var allSubmissions: [[String]]

}
