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
    @State var input: String = ""

    var body: some View {
        VStack {
            GameClock(count: $viewModel.wordsCount, globalHighScore: 5)
                .padding(.horizontal, 20)
            Spacer()
            VStack(spacing: 60) {
                VStack {
                    // MARK: Title
                    Text(attributedTitle)
                        .gameInputText(tracking: textTracking)
                        .background(ContiguousRectangles(count: viewModel.word.count, spacing: letterSpacing, cornerRadius: letterSpacing, colors: validationColors))
                        .padding(letterSpacing)
                        .background(
                            RoundedRectangle(cornerRadius: letterSpacing)
                                .fill(completed ? .success.opacity(0.5) : Color.gray.opacity(0.1))
                        )

                    // MARK: Entries
                    ScrollViewReader { scrollViewProxy in
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 20) {
                                ForEach(0..<viewModel.words.count, id: \.self) { index in
                                    Text(attributedText(at: index))
                                        .gameInputText(tracking: textTracking)
                                        .foregroundColor(.secondaryFont)
                                        .background(ContiguousRectangles(count: viewModel.word.count, spacing: letterSpacing, cornerRadius: letterSpacing, colors: colors(for: viewModel.words[index])))
                                }
                            }
                        }
                        .onChange(of: viewModel.words) { newValue in
                            withAnimation {
                                scrollViewProxy.scrollTo(newValue.count - 1, anchor: .bottom)
                            }
                        }
                    }

                    // MARK: Input box
                    HStack(spacing: 0) {
                        ForEach(0..<viewModel.word.count, id: \.self) { wordIndex in
                            Text(input(at: wordIndex))
                                .gameInputText(tracking: textTracking)
                                .foregroundColor(.secondaryFont)
                        }
                    }
                    .background(ContiguousRectangles(count: viewModel.word.count, spacing: letterSpacing, cornerRadius: letterSpacing, colors: [.gray.opacity(0.15)]))

                }
                .frame(width: gameFrameSize().width, height: gameFrameSize().height)
                .fixedSize()

                // MARK: Keyboard
                GameKeyboard(key: $keyboardInput)
                    .onChange(of: keyboardInput) { newValue in
                        if let newValue = newValue, newValue.isLetter, input.count < viewModel.word.count {
                            input += String(newValue)
                        } else if newValue == "⌫", input.count > 0 {
                            input.remove(at: input.index(before: input.endIndex))
                        } else if newValue == "⏎", input.count == viewModel.word.count {
                            viewModel.submit(input)
                            input = ""
                        }
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
        viewModel.word.count < 20 ? 4.0 : 2.0
    }

    private var textTracking: CGFloat {
        letterSpacing * 4
    }

    private func input(at index: Int) -> String {
        if index < input.count {
            return String(input[index])
        }
        return " "
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
        viewModel.matchMap.map { $0 ? .success : .failure }
    }

    private func colors(for word: String) -> [Color] {
        var colors = Array(repeating: Color.gray.opacity(0.05), count: word.count)
        for (index, value) in word.enumerated() {
            if value.lowercased() == viewModel.word[index].lowercased() && viewModel.matchMap[index] {
                colors[index] = .success.opacity(0.5)
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

extension Text {
    func digitalText(_ size: UIFont.TextStyle = .title2) -> some View {
        modifier(DigitalText(size: size))
    }

    func gameInputText(_ size: UIFont.TextStyle = .largeTitle, tracking: CGFloat = 0) -> some View {
        modifier(GameInputText(size: size, tracking: tracking))
    }
}
