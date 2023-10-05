//
//  GameViewModel.swift
//  WordPin
//
//  Created by Yida Zhang on 7/24/23.
//

import Foundation
import Combine
import UIKit

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
    @Published var input: String
    @Published var gameFinished: Bool = false

    var shake = PassthroughSubject<Void, Never>()

    static let idealFont: UIFont.TextStyle = .largeTitle

    init(_ word: String) {
        self.word = word
        self.matchMap = Array(repeating: false, count: word.count)
        self.input = String(repeating: ".", count: word.count)
    }

    func updateInput(_ newValue: Character?) -> Completion<String, QuizError> {
        if let newValue = newValue, newValue.isLetter, let spaceIndex = input.firstIndex(of: ".") {
            input.replaceSubrange(spaceIndex..<input.index(after: spaceIndex), with: [newValue])
        } else if newValue == "⌫" {
            if let spaceIndex = input.firstIndex(of: "."), spaceIndex != input.startIndex {
                input.replaceSubrange(input.index(before: spaceIndex)..<spaceIndex, with: ["."])
            } else {
                input.replaceSubrange(input.index(before: input.endIndex)..<input.endIndex, with: ["."])
            }
        } else if newValue == "⏎", input.firstIndex(of: ".") == nil {
            let completion = tryWordSubmission(input)
            if case .success(_) = completion {
                input = String(repeating: ".", count: word.count)
            }
            return .completed(completion)
        }
        return .incomplete
    }

    func tryWordSubmission(_ entry: String) -> Result<String, QuizError> {
        let validity = valid(entry)

        switch validity {
        case .success(let success):
            addWord(success)
        case .failure(let failure):
            switch failure {
            case .repeatTitle:
                break
            case .repeatEntry(_):
                break
            case .invalidVocabulary:
                break
            }
        }
        return validity
    }

    func addWord(_ word: String) {
        words.append(word.lowercased())
        updateMatchMap(with: word)
    }

    func needShake() { shake.send() }

    private func updateMatchMap(with entry: String) {
        for charIdx in 0..<word.count {
            if word[charIdx].lowercased() == entry[charIdx].lowercased() {
                matchMap[charIdx].toggle()
            }
        }
        if matchMap.reduce(true, { $0 && $1 }) {
            completeGame()
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
                return .failure(.repeatEntry(comparableInput))
            }
        } else  {
            return .failure(.repeatTitle)
        }
    }

    private func completeGame() {
        gameFinished = true
        // TODO: Uncomment save
        if let submission = PersistenceController.shared.save(word: word, group: words) as? Submission {
            Task(priority: .background) {
                try? await URLTask.shared.postSubmission(submission)
            }
        }
    }
}

enum QuizError: Error {
    case repeatTitle
    case repeatEntry(String)
    case invalidVocabulary
}

enum Completion<Value, Failure: Error> {
    case completed(Result<Value, Failure>)
    case incomplete
}
