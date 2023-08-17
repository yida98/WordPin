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
            Spacer()
            VStack(spacing: 60) {
                VStack(spacing: 20) {
                    // MARK: Title
                    Text(attributedTitle)
                        .textBackground(word: viewModel.word, colors: validationColors)
                    // MARK: Entries
                    ScrollViewReader { scrollViewProxy in
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 20) {
                                ForEach(0..<viewModel.words.count, id: \.self) { index in
                                    Text(attributedText(at: index))
                                        .textBackground(word: viewModel.word, colors: colors(for: viewModel.words[index]))
                                        .foregroundColor(.secondaryFont)
                                }
                            }
                        }.frame(width: gameFrameSize().width, height: gameFrameSize().height)
                        .onChange(of: viewModel.words) { newValue in
                            withAnimation {
                                scrollViewProxy.scrollTo(newValue.count - 1, anchor: .bottom)
                            }
                        }
                    }
                    .frame(width: gameFrameSize().width, height: gameFrameSize().height)

                    // MARK: Input box
                    HStack(spacing: 0) {
                        Text(attributedInput)
                            .textBackground(word: viewModel.word, colors: [.gray.opacity(0.15)])
                    }
                }.frame(width: gameFrameSize().width)

                // MARK: Keyboard
                GameKeyboard(key: $keyboardInput)
                    .onChange(of: keyboardInput) { newValue in
                        viewModel.updateInput(newValue)
                        keyboardInput = nil
                    }
            }
            Spacer()
        }.scenePadding(.minimum, edges: .all)
            .background(Color.background)
    }
    
    private func gameFrameSize() -> CGSize {
        let width = Constant.screenBounds.width - 80
        let height = Constant.screenBounds.height / 2.5
        return CGSize(width: width, height: height)
    }
    
    private var letterSpacing: CGFloat {
        if viewModel.word.count < 12 {
            return 4
        } else if viewModel.word.count < 20 {
            return 2
        } else {
             return 1
        }
    }

    private var textTracking: CGFloat {
        var multiplier: CGFloat
        if viewModel.word.count < 12 {
            multiplier = 4
        } else if viewModel.word.count < 20 {
            multiplier = 2
        } else {
            multiplier = 1
        }
        return letterSpacing * multiplier
    }

    private var cornerRadius: CGFloat {
        4.0
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

    func attributedText(at index: Int) -> AttributedString {
        guard index < viewModel.words.count else { return AttributedString() }

        var text = AttributedString(viewModel.words[index].uppercased())
        let originalWord = viewModel.word.uppercased()
        for charIdx in 0..<text.characters.count {
            let currentIndex = text.characters.index(text.startIndex, offsetBy: charIdx)
            if originalWord[charIdx] == text.characters[currentIndex] {
//                text[currentIndex..<text.characters.index(after: currentIndex)].font = UIFont.monospaced(size: .largeTitle, emphasis: .bold)
                text[currentIndex..<text.characters.index(after: currentIndex)].foregroundColor = .jade
            }
        }

        return text
    }

    private var validationColors: [Color] {
        viewModel.matchMap.map { $0 ? .success.opacity(0.65) : .failure.opacity(0.65) }
    }

    private func colors(for word: String) -> [Color] {
        var colors = Array(repeating: Color.gray.opacity(0.05), count: word.count)
        for (index, value) in word.enumerated() {
            if value.lowercased() == viewModel.word[index].lowercased() && viewModel.matchMap[index] {
                colors[index] = .success.opacity(0.65)
            }
        }
        return colors
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

struct TextBackground: ViewModifier {
    let word: String
    let colors: [Color]

    init(word: String, colors: [Color]) {
        self.word = word
        self.colors = colors
    }

    func body(content: Content) -> some View {
        content
            .gameInputText(tracking: tracking)
            .background(ContiguousRectangles(count: word.count, spacing: tracking - padding, cornerRadius: cornerRadius, colors: colors))
    }

    var textSize: CGSize {
        let font: UIFont = .monospaced(size: GameViewModel.idealFont)
        let textSize = "a".size(withAttributes: [.font: font])
        return textSize
    }

    var padding: CGFloat {
        estimatedTrueWidth * 0.1
    }

    var cornerRadius: CGFloat {
        estimatedTrueWidth * 0.2
    }

    var tracking: CGFloat {
        estimatedTrueWidth * 0.2
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

    func textBackground(word: String, colors: [Color]) -> some View {
        modifier(TextBackground(word: word, colors: colors))
    }
}
