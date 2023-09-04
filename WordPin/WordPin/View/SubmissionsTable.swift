//
//  SubmissionsTable.swift
//  WordPin
//
//  Created by Yida Zhang on 7/13/23.
//

import SwiftUI

struct SubmissionsTable: View {
    @ObservedObject var viewModel: WordCollectionViewModel
    @State private var selectedWord: String?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                ForEach(viewModel.wordList.indices, id: \.self) { index in
                    HStack {
                        Text(viewModel.wordList[index].submission.word ?? " NULL")
                            .gameText()
                        Spacer()
                        Text(viewModel.wordList[index].submission.group?.count == nil ? "NULL" : String(viewModel.wordList[index].submission.group!.count))
                            .gameText()
                            .minimumScaleFactor(0.5)
                            .frame(width: 50)
                        Text(globalScore(at: index))
                            .gameText()
                            .minimumScaleFactor(0.5)
                            .frame(width: 50)
                    }
                    .onTapGesture {
                        selectedWord = "superfragaliciousespialidocious"
                        selectedWord = "lo"
                    }
                }
            }.sheet(item: $selectedWord) {
                // TODO: On dismiss save
            } content: { value in
                GameView(viewModel: GameViewModel(value))
            }
        }
    }

    private func globalScore(at index: Int) -> String {
        guard let group = viewModel.wordList[index].globalHighScore.group else {
            return "NULL"
        }
        return String(group.count)
    }
}

extension String: Identifiable {
    public var id: String { self }
}

extension Text {
    func gameText(_ size: UIFont.TextStyle = .title3) -> some View {
        modifier(GameText(size: size))
    }
}

struct GameText: ViewModifier {
    let size: UIFont.TextStyle
    
    func body(content: Content) -> some View {
        content
            .font(.monospaced(size: size))
            .foregroundColor(.primaryFont)
    }
}
