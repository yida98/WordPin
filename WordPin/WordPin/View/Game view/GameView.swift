//
//  GameView.swift
//  WordPin
//
//  Created by Yida Zhang on 7/13/23.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var keyboardInput: Character?

    var body: some View {
        VStack {
            GameClock(count: $viewModel.wordsCount, globalHighScore: 5)
                .padding(.horizontal, 20)
            Spacer(minLength: 0)
            VStack(spacing: 40) {
                VStack(spacing: 20) {
                    // MARK: Title
                    Text(attributedTitle)
                        .textBackground(word: viewModel.word, colors: validationColors)
                        .frame(maxWidth: gameFrameSize().width)
                        .fixedSize(horizontal: false, vertical: true)
                    // MARK: Entries
                    GameInputList(viewModel: viewModel, gameFrameSize: gameFrameSize())

                    // MARK: Input box
                    Text(attributedInput)
                        .textBackground(word: viewModel.word, colors: [.gray.opacity(0.15)]) {
                            Text(String(describing: viewModel.wordsCount + 1))
                                .labelText()
                        }
                        .frame(maxWidth: gameFrameSize().width)
                        .fixedSize(horizontal: false, vertical: true)
                }.frame(width: gameFrameSize().width)

                // MARK: Keyboard
                GameKeyboard(key: $keyboardInput)
                    .onChange(of: keyboardInput) { newValue in
                        viewModel.updateInput(newValue)
                        keyboardInput = nil
                    }
            }
        }
        .padding(.bottom, 80)
        .scenePadding(.minimum, edges: .all)
        .background(Color.background)
    }
    
    private func gameFrameSize() -> CGSize {
        let width = Constant.screenBounds.width - 80
        let height = Constant.screenBounds.height / 3.5
        return CGSize(width: width, height: height)
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

    private var attributedTitle: AttributedString {
        var title = AttributedString(viewModel.word.uppercased())

        for charIdx in 0..<title.characters.count {
            let currentIndex = title.characters.index(title.characters.startIndex, offsetBy: charIdx)
            if charIdx < viewModel.matchMap.count, viewModel.matchMap[charIdx] {
                title[currentIndex..<title.characters.index(after: currentIndex)].foregroundColor = .jade
            } else {
                title[currentIndex..<title.characters.index(after: currentIndex)].foregroundColor = .tertiaryFont
            }
        }

        return title
    }

    private var validationColors: [Color] {
        viewModel.matchMap.map { $0 ? .success.opacity(0.65) : .failure.opacity(0.65) }
    }

    private var completed: Bool {
        viewModel.matchMap.reduce(true) { return $0 && $1 }
    }
}

struct DigitalText: ViewModifier {
    let size: UIFont.TextStyle
    func body(content: Content) -> some View {
        content
            .font(.digitalFont(size: size))
    }
}

struct GameInputText: ViewModifier {
    let size: UIFont.TextStyle
    let tracking: CGFloat
    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.center)
            .font(.monospaced(size: size))
            .minimumScaleFactor(0.1)
            .lineLimit(1)
            .tracking(tracking)
    }
}

struct TextBackground<Label: View>: ViewModifier {
    let word: String
    let colors: [Color]
    let label: () -> Label

    init(word: String, colors: [Color], label: @escaping () -> Label) {
        self.word = word
        self.colors = colors
        self.label = label
    }

    func body(content: Content) -> some View {
        content
            .gameInputText(tracking: tracking)
            .background(
                GeometryReader { proxy in
                    ContiguousRectangles(count: word.count, spacing: tracking - padding, cornerRadius: cornerRadius, colors: colors)
                        .overlay(
                            VStack {
                                label()
                                Spacer(minLength: 0)
                            }
                                .offset(x: -(proxy.size.width/2) - 10)
                        )
                })
    }

    var textSize: CGSize {
        let font: UIFont = .monospaced(size: GameViewModel.idealFont)
        let textSize = "a".size(withAttributes: [.font: font])
        return textSize
    }

    var padding: CGFloat {
        estimatedTrueWidth * 0.35
    }

    var cornerRadius: CGFloat {
        estimatedTrueWidth * 0.3
    }

    var tracking: CGFloat {
        estimatedTrueWidth * 0.45
    }

    var estimatedTrueWidth: CGFloat {
        let fullLength = CGFloat(word.count) * textSize.width
        let maxWidth = Constant.screenBounds.width - 80
        var scale: CGFloat = 1

        if fullLength > maxWidth {
            scale = maxWidth / fullLength
        }

        return textSize.width * scale
    }
}

extension View {
    func digitalText(_ size: UIFont.TextStyle = .title2) -> some View {
        modifier(DigitalText(size: size))
    }

    func gameInputText(_ size: UIFont.TextStyle = GameViewModel.idealFont, tracking: CGFloat = 0) -> some View {
        modifier(GameInputText(size: size, tracking: tracking))
    }

    func labelText() -> some View {
        self
            .font(.monospaced(size: .caption1))
            .foregroundColor(.jade.opacity(0.5))
    }

    func textBackground<Label: View>(word: String, colors: [Color], label: @escaping () -> Label = { EmptyView() }) -> some View {
        modifier(TextBackground(word: word, colors: colors, label: label))
    }
}
