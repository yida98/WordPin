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

    init(_ word: String? = nil) {
        self.word = word ?? ""
        self.matchMap = Array(repeating: false, count: word?.count ?? 0)
        self.input = String(repeating: ".", count: word?.count ?? 0)

        if word == nil {
            Task { [weak self] in
                if let newWord = try? await URLTask.shared.getNewWord().first {
                    await MainActor.run { [weak self] in
                        self?.word = newWord
                        self?.matchMap = Array(repeating: false, count: newWord.count)
                        self?.input = String(repeating: ".", count: newWord.count)
                    }
                }
            }
        }
    }

    func updateInput(_ newValue: Character?) -> Completion<String, QuizError> {
//        if let newValue = newValue, newValue.isLetter, input.count < word.count {
//            input += String(newValue)
//        } else if newValue == "⌫", input.count > 0 {
//            input.remove(at: input.index(before: input.endIndex))
//        } else if newValue == "⏎", input.count == word.count {
//            submit(input)
//            input = nil
//        }
        if let newValue = newValue, newValue.isLetter, let spaceIndex = input.firstIndex(of: ".") {
            input.replaceSubrange(spaceIndex..<input.index(after: spaceIndex), with: [newValue])
        } else if newValue == "⌫" {
            if let spaceIndex = input.firstIndex(of: "."), spaceIndex != input.startIndex {
                input.replaceSubrange(input.index(before: spaceIndex)..<spaceIndex, with: ["."])
            } else {
                input.replaceSubrange(input.index(before: input.endIndex)..<input.endIndex, with: ["."])
            }
        } else if newValue == "⏎", input.firstIndex(of: ".") == nil {
            let completion = submit(input)
            if case .success(_) = completion {
                input = String(repeating: ".", count: word.count)
            }
            return .completed(completion)
        }
        return .incomplete
    }

    func submit(_ entry: String) -> Result<String, QuizError> {
        let validity = valid(entry)

        switch validity {
        case .success(let success):
            updateMatchMap(with: success)
            words.append(success.lowercased())

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

    func needShake() { shake.send() }

    private func updateMatchMap(with entry: String) {
        for charIdx in 0..<word.count {
            if word[charIdx].lowercased() == entry[charIdx].lowercased() {
                matchMap[charIdx].toggle()
            }
        }
        if matchMap.reduce(true, { $0 && $1 }) {
            gameFinished = true
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
