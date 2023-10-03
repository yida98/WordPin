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

    @Published var loadingGame: Bool = false

    init() {
        self.displayName = AppData.shared.displayName
        Task { [weak self] in
            await self?.fetchDailyWord()
        }
    }

    func makeNewGame(_ word: String?) async {
        if let word = word {
            await MainActor.run { [weak self] in
                self?.currentGame = GameViewModel(word)
            }
        }
    }

    func fetchDailyWord() async {
        DispatchQueue.main.async { [weak self] in
            self?.loadingGame = true
        }

        let fetchWordTask = Task(priority: .background) { [weak self] in
            let word = try? await URLTask.shared.getDailyWord()
            await self?.makeNewGame(word)
            DispatchQueue.main.async { [weak self] in
                self?.word = word
                self?.loadingGame = false
            }
        }

        let timeOutTask = Task {
            try await Task.sleep(nanoseconds: UInt64(4) * NSEC_PER_SEC)
            fetchWordTask.cancel()
            DispatchQueue.main.async { [weak self] in
                self?.loadingGame = false
            }
        }


        await fetchWordTask.value
        timeOutTask.cancel()
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

    func restartGame() {
        debugPrint("restart game")
        if let word = word {
            Task {
                await makeNewGame(word)
            }
        }
    }
}

struct LeaderboardUser {
    var userID: String
    var allSubmissions: [[String]]

}
