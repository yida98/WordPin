//
//  GameFunctionView.swift
//  WordPin
//
//  Created by Yida Zhang on 8/21/23.
//

import SwiftUI

struct GameFunctionView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var keyboardInput: Character?
    @State private var errorMessage: String = " "

    @State private var shouldShake: Bool = false

    let gameFrameSize: CGSize

    var body: some View {
        VStack(spacing: 40) {
            // MARK: Input box
            VStack {
                Text(attributedInput)
                    .textBackground(word: viewModel.word, colors: [.gray.opacity(0.15)]) {
                        Text(String(describing: viewModel.wordsCount + 1))
                            .labelText()
                    }
                    .frame(maxWidth: gameFrameSize.width)
                    .fixedSize(horizontal: false, vertical: true)
                    .shakeAnimation($shouldShake, sink: viewModel.shake)
                Text(errorMessage)
                    .font(.primary(size: .caption2, emphasis: .italic))
                    .foregroundColor(.tertiaryFont)
                    .onChange(of: errorMessage) { newValue in
                        if newValue != " " {
                            withAnimation(.easeOut(duration: 3)) {
                                errorMessage = " "
                            }
                        }
                    }
            }.frame(width: gameFrameSize.width)

            // MARK: Keyboard
            GameKeyboard(key: $keyboardInput)
                .disabled(viewModel.gameFinished)
                .onChange(of: keyboardInput) { newValue in
                    Task(priority: .background) {
                        let competion = await viewModel.updateInput(newValue)
                        switch competion {
                        case .completed(let result):
                            switch result {
                            case .success(_):
                                // TODO: Do something
                                break
                            case .failure(let error):
                                withAnimation {
                                    shouldShake.toggle()
                                }
                                switch error {
                                case .repeatTitle:
                                    errorMessage = "Cannot repeat target word"
                                case .invalidVocabulary:
                                    errorMessage = "Invalid vocabulary"
                                case .repeatEntry(let word):
                                    errorMessage = "Repeating \"\(word)\""
                                }
                            }
                        case .incomplete:
                            // TODO: Do something
                            break
                        }
                        DispatchQueue.main.async {
                            keyboardInput = nil
                        }
                    }
                }
        }
    }

    private var attributedInput: AttributedString {
        var title = AttributedString(viewModel.input.uppercased())

        for (ind, c) in title.characters.enumerated() {
            let currentIndex = title.characters.index(title.characters.startIndex, offsetBy: ind)
            if ind < viewModel.input.count{
                if c == "." {
                    title[currentIndex..<title.characters.index(after: currentIndex)].foregroundColor = .clear
                } else {
                    title[currentIndex..<title.characters.index(after: currentIndex)].foregroundColor = .jade
                }
            }
        }

        return title
    }

    private var completed: Bool {
        viewModel.matchMap.reduce(true) { return $0 && $1 }
    }
}
