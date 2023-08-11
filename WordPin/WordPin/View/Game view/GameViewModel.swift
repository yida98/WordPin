//
//  GameViewModel.swift
//  WordPin
//
//  Created by Yida Zhang on 7/24/23.
//

import Foundation
import Combine

class GameViewModel: ObservableObject {
    /// Display of the words will always be uppercased, however, they are fetched and saved as lowercased.
    @Published var words = [String]() {
        didSet {
            wordsCount = words.count
        }
    }
    @Published var word: String
    @Published var wordsCount = 0
    @Published var matchMap: [Bool]

    init(_ word: String? = nil) {
        self.word = word ?? ""
        self.matchMap = Array(repeating: false, count: word?.count ?? 0)

        if word == nil {
            Task(priority: .background) { [weak self] in
                if let newWord = try? await URLTask.shared.getNewWord().first {
                    self?.word = newWord
                    self?.matchMap = Array(repeating: false, count: newWord.count)
                }
            }
        }
    }

    func submit(_ entry: String) {
        let validity = valid(entry)

        switch validity {
        case .success(let success):
            updateMatchMap(with: success)
            words.append(success.lowercased())

        case .failure(let failure):
            switch failure {
            case .sameInput:
                break
            case .repeatEntry:
                break
            case .invalidVocabulary:
                break
            }
        }
    }

    private func updateMatchMap(with entry: String) {
        for charIdx in 0..<word.count {
            if word[charIdx].lowercased() == entry[charIdx].lowercased() {
                matchMap[charIdx].toggle()
            }
        }
    }

    private func valid(_ entry: String) -> Result<String, QuizError> {
        let comparator = word.lowercased()
        let comparableInput = entry.lowercased()

        if comparator != comparableInput {
            if !words.contains(comparableInput) {
                // TODO: Check validity of vocabulary
                return .success(entry)
            } else {
                return .failure(.repeatEntry)
            }
        } else  {
            return .failure(.sameInput)
        }
    }
}

enum QuizError: Error {
    case sameInput
    case repeatEntry
    case invalidVocabulary
}
