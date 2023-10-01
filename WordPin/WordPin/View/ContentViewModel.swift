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
    @Published var word: String?
    private var localSubmissionsSubscriber = Set<AnyCancellable>()

    init() {
        self.displayName = AppData.shared.displayName
        Task(priority: .background) { [weak self] in
            let word = try? await URLTask.shared.getDailyWord()
            await self?.makeNewGame(word)
            await MainActor.run { [weak self] in
                self?.word = word
            }
        }
    }

    func makeNewGame(_ word: String?) async {
        if let word = word {
            await MainActor.run { [weak self] in
                self?.currentGame = GameViewModel(word)
            }
        }
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
}

struct LeaderboardUser {
    var userID: String
    var allSubmissions: [[String]]

}
