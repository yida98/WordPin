//
//  WordCollectionViewModel.swift
//  WordPin
//
//  Created by Yida Zhang on 7/14/23.
//

import Foundation
import Combine

class WordCollectionViewModel: ObservableObject {
    @Published var isPresentingGame: Bool = false
    @Published var wordList: [AggregatedSubmission] = []
    var currentGame: GameViewModel?
    private var localSubmissionsSubscriber = Set<AnyCancellable>()
    
    init() {
        refresh()

        PersistenceController.shared.objectWillChange
            .sink { [weak self] _ in
                self?.refresh()
            }
            .store(in: &localSubmissionsSubscriber)
    }

    func refresh() {
        Task(priority: .background) {
            if let wordList = PersistenceController.shared.fetchAll() as? [Submission] {
                await MainActor.run { [weak self] in
                    self?.wordList = wordList.map { AggregatedSubmission(submission: $0) }
                }
            }
        }
    }
    
    func playNewGame() {
        Task { [weak self] in
            if let _ = await self?.makeNewGame() {
                await MainActor.run { [weak self] in
                    self?.isPresentingGame = true
                }
            }
        }
    }

    func makeNewGame(_ word: String? = nil) async -> GameViewModel? {
        if let word = word {
            self.currentGame = GameViewModel(word)
        } else {
            if let newWord = try? await URLTask.shared.getNewWord().first {
                self.currentGame = GameViewModel(newWord)
            }
        }
        return self.currentGame
    }

    func finishedGame() {
        // TODO: Take the game stats and upload it
        if let currentGame = currentGame, currentGame.gameFinished {
            if let submission = PersistenceController.shared.save(word: currentGame.word, group: currentGame.words) as? Submission {
                // TODO: UserID not created
//                URLTask.shared.postSubmission(submission)
            }
        }
        // TODO: Continue the game until new game
        self.currentGame = nil
    }

    // TODO: Delete row
}

class AggregatedSubmission {
    var submission: Submission
    var globalHighScore: Submission

    init(submission: Submission) {
        self.submission = submission
        self.globalHighScore = submission

        Task(priority: .background) {
            if let word = submission.word, case .success(let submissions) = await URLTask.shared.getSubmissions(for: word), let firstSubmission = submissions.first {
                let bestSubmission = submissions.reduce(firstSubmission) { partialResult, newValue in
                    if let lhsGroup = partialResult.group, let rhsGroup = newValue.group {
                        return lhsGroup.count < rhsGroup.count ? partialResult : newValue
                    }
                    return partialResult
                }
                await MainActor.run { [weak self] in
                    self?.globalHighScore = bestSubmission
                }
            }
        }
    }
}
