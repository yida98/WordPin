//
//  WordCollectionViewModel.swift
//  WordPin
//
//  Created by Yida Zhang on 7/14/23.
//

import Foundation

class WordCollectionViewModel: ObservableObject {
    @Published var isPresentingGame: Bool = false
    
    init() {
        
    }
    
    func playNewGame() {
        isPresentingGame = true
    }

    func makeNewGame(_ word: String? = nil) -> GameViewModel {
        GameViewModel(word)
    }
}
