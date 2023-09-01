//
//  WordCollectionViewModel.swift
//  WordPin
//
//  Created by Yida Zhang on 7/14/23.
//

import Foundation

class WordCollectionViewModel: ObservableObject {
    @Published var isPresentingGame: Bool = false
    @Published var wordList: [Submission] = []
    var currentGame: GameViewModel?
    
    init() {
        
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
        self.currentGame = nil
    }
}
