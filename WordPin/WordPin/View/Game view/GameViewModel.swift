//
//  GameViewModel.swift
//  WordPin
//
//  Created by Yida Zhang on 7/24/23.
//

import Foundation
import Combine
import UIKit

class GameViewModel: ObservableObject, Codable {
    /// Display of the words will always be uppercased, however, they are fetched and saved as lowercased.
    @Published var words = [String]() {
        didSet {
            wordsCount = Int32(words.count)
        }
    }
    @Published var word: String
    @Published var wordsCount: Int32 = 0
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

    enum CodingKeys: String, CodingKey {
        case words, word, wordsCount, matchMap, input, gameFinished
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.words = try container.decode([String].self, forKey: .words)
        self.word = try container.decode(String.self, forKey: .word)
        self.wordsCount = try container.decode(Int32.self, forKey: .wordsCount)
        self.matchMap = try container.decode([Bool].self, forKey: .matchMap)
        self.input = try container.decode(String.self, forKey: .input)
        self.gameFinished = try container.decode(Bool.self, forKey: .gameFinished)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(words, forKey: .words)
        try container.encode(word, forKey: .word)
        try container.encode(wordsCount, forKey: .wordsCount)
        try container.encode(matchMap, forKey: .matchMap)
        try container.encode(String(repeating: ".", count: word.count), forKey: .input)
        try container.encode(gameFinished, forKey: .gameFinished)
    }

    @MainActor
    func updateInput(_ newValue: Character?) async -> Completion<String, QuizError> {
        if let newValue = newValue, newValue.isLetter, let spaceIndex = input.firstIndex(of: ".") {
            input.replaceSubrange(spaceIndex..<input.index(after: spaceIndex), with: [newValue])
        } else if newValue == "⌫" {
            if let spaceIndex = input.firstIndex(of: "."), spaceIndex != input.startIndex {
                input.replaceSubrange(input.index(before: spaceIndex)..<spaceIndex, with: ["."])
            } else {
                input.replaceSubrange(input.index(before: input.endIndex)..<input.endIndex, with: ["."])
            }
        } else if newValue == "⏎", input.firstIndex(of: ".") == nil {
            let completion = await tryWordSubmission(input)
            if case .success(_) = completion {
                input = String(repeating: ".", count: word.count)
            }
            return .completed(completion)
        }
        return .incomplete
    }

    @MainActor
    func tryWordSubmission(_ entry: String) async -> Result<String, QuizError> {
        let validity = await valid(entry)

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
        if allMatched() {
            completeGame()
        } else {
            try? AppData.shared.saveSession(self)
        }
    }

    func needShake() { shake.send() }

    private func updateMatchMap(with entry: String) {
        for charIdx in 0..<word.count {
            if word[charIdx].lowercased() == entry[charIdx].lowercased() {
                matchMap[charIdx].toggle()
            }
        }
    }

    private func allMatched() -> Bool {
        return matchMap.reduce(true, { $0 && $1 })
    }

    private func valid(_ entry: String) async -> Result<String, QuizError> {
        let comparator = word.lowercased()
        let comparableInput = entry.lowercased()

        if comparator != comparableInput {
            if !words.contains(comparableInput) {
                // TODO: Check validity of vocabulary
                
                if let vocabularyValidity = try? await URLTask.shared.getValidity(of: comparableInput), vocabularyValidity {
                    return .success(entry)
                } else {
                    return .failure(.invalidVocabulary)
                }
            } else {
                return .failure(.repeatEntry(comparableInput))
            }
        } else  {
            return .failure(.repeatTitle)
        }
    }

    private func completeGame() {
        gameFinished = true
        try? AppData.shared.removeSession()
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
