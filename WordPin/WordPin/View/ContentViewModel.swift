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
    private var localSubmissionsSubscriber = Set<AnyCancellable>()

    init() {
        Task { [weak self] in
            await self?.makeNewGame()
        }
    }

    func makeNewGame(_ word: String? = "nil") async -> GameViewModel? {
        if let word = word {
            self.currentGame = GameViewModel(word)
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
}
