//
//  PlayerHistory.swift
//  WordPin
//
//  Created by Yida Zhang on 10/2/23.
//

import SwiftUI

struct PlayerHistory: View {
    @State private var indices = [0]

    private let block = 10
    @State private var max: Int = 0
    @State private var history: [HistoryCellData]?
    @State private var searchText: String = ""

    var body: some View {
        VStack {
            HStack {
                Text("Word")
                    .font(.monospaced(size: .caption1, emphasis: .bold))
                    .foregroundColor(.jadeShadow)
                Spacer()
                Text("Record")
                    .font(.monospaced(size: .caption1, emphasis: .bold))
                    .foregroundColor(.jade)
            }
            .padding()
            Spacer(minLength: 0)
            if let history = history, history.count > 0 {
                List {
                    ForEach(indices, id: \.self) { index in
                        PlayerHistoryCell(history: history[index])
                            .onAppear {

                                // load next block when last row shown (or can be
                                // tuned to preload in advance)

                                if indices.last == index && index < max {
                                    let next = max - index
                                    indices.append(contentsOf:
                                                    Array(index + 1..<index+(next > block ? block : next)))
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                Image(systemName: "star.slash")
                    .foregroundColor(.secondaryFont)
                Text("Nothing yet")
                    .foregroundColor(.secondaryFont)
                    .font(.monospaced(size: .caption1, emphasis: .bold))
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 40)
        .onAppear {
            fetchSubmissions()
        }
    }

    // Not lazily loading the data
    private func fetchSubmissions() {
        if let submissions = PersistenceController.shared.fetchAll() {
            var wordsToRecords = [String: Int32]()
            let orderedWords: [String] = submissions.compactMap { submission -> String? in
                guard let word = submission.word else { return nil }
                if let value = wordsToRecords[word] {
                    wordsToRecords[word] = min(value, submission.groupCount)
                } else {
                    wordsToRecords[word] = submission.groupCount
                }
                return word
            }
            max = history?.count ?? 0
            history = orderedWords.compactMap {
                if let record = wordsToRecords[$0] {
                    return HistoryCellData(word: $0, record: record)
                }
                return nil
            }
        }
        max = 53
        history = [.init(word: "doing", record: 3),
                   .init(word: "magnus", record: 5),
                   .init(word: "escape", record: 4),
                   .init(word: "rook", record: 2),
                   .init(word: "all", record: 5),
                   .init(word: "afoiwj", record: 4),
                   .init(word: "alumni", record: 2),
                   .init(word: "enpassant", record: 5),
                   .init(word: "ptermisluasquamia", record: 4),
                   .init(word: "sfdsgh", record: 2),
                   .init(word: "sfgja", record: 2),
                   .init(word: "enpjassant", record: 5),
                   .init(word: "pojqaptermisluasquamia", record: 4),
                   .init(word: "sdfasdf", record: 2),
                   .init(word: "magnus", record: 5),
                   .init(word: "escape", record: 4),
                   .init(word: "rook", record: 2),
                   .init(word: "all", record: 5),
                   .init(word: "afoiwj", record: 4),
                   .init(word: "alumni", record: 2),
                   .init(word: "enpassant", record: 5),
                   .init(word: "ptermisluasquamia", record: 4),
                   .init(word: "sfdsgh", record: 2),
                   .init(word: "sfgja", record: 2),
                   .init(word: "enpjassant", record: 5),
                   .init(word: "pojqaptermisluasquamia", record: 4),
                   .init(word: "sdfasdf", record: 2),
                   .init(word: "magnus", record: 5),
                   .init(word: "escape", record: 4),
                   .init(word: "rook", record: 2),
                   .init(word: "all", record: 5),
                   .init(word: "afoiwj", record: 4),
                   .init(word: "alumni", record: 2),
                   .init(word: "enpassant", record: 5),
                   .init(word: "ptermisluasquamia", record: 4),
                   .init(word: "sfdsgh", record: 2),
                   .init(word: "sfgja", record: 2),
                   .init(word: "enpjassant", record: 5),
                   .init(word: "pojqaptermisluasquamia", record: 4),
                   .init(word: "sdfasdf", record: 2),
                   .init(word: "magnus", record: 5),
                   .init(word: "escape", record: 4),
                   .init(word: "rook", record: 2),
                   .init(word: "all", record: 5),
                   .init(word: "afoiwj", record: 4),
                   .init(word: "alumni", record: 2),
                   .init(word: "enpassant", record: 5),
                   .init(word: "ptermisluasquamia", record: 4),
                   .init(word: "sfdsgh", record: 2),
                   .init(word: "sfgja", record: 2),
                   .init(word: "enpjassant", record: 5),
                   .init(word: "pojqaptermisluasquamia", record: 4),
                   .init(word: "sdfasdf", record: 2)]
    }
}

struct HistoryCellData {
    var word: String
    var record: Int32
}
