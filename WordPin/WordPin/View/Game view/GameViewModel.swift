//
//  GameViewModel.swift
//  WordPin
//
//  Created by Yida Zhang on 7/24/23.
//

import Foundation
import Combine

class GameViewModel: ObservableObject {
    @Published var words = [String]() {
        didSet {
            wordCount = words.count
        }
    }
    @Published var word: String
    @Published var wordCount = 0

    init(_ word: String) {
        self.word = word


    }

    func submit(_ word: String) {
        if !words.contains(word) {
            words.append(word)
        } else {
            // TODO: Display error
        }
    }
}
