//
//  GameInputList.swift
//  WordPin
//
//  Created by Yida Zhang on 8/17/23.
//

import SwiftUI

struct GameInputList: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var contentSize: CGSize = .zero
    var gameFrameSize: CGSize

    var body: some View {
        // MARK: Entries
        ScrollViewReader { scrollViewProxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    ForEach(0..<viewModel.words.count, id: \.self) { index in
                        Text(attributedText(at: index))
                            .foregroundColor(.secondaryFont)
                            .textBackground(word: viewModel.word, colors: colors(for: viewModel.words[index])) {
                                Text(String(describing: index + 1))
                                    .labelText()
                            }
                            .frame(width: gameFrameSize.width)
                    }
                }
                .getSize { contentSize = $0 }
            }
            .frame(width: gameFrameSize.width, height: min(contentSize.height, gameFrameSize.height))
            .onChange(of: viewModel.words) { newValue in
                withAnimation {
                    scrollViewProxy.scrollTo(newValue.count - 1, anchor: .bottom)
                }
            }
        }
        .frame(width: gameFrameSize.width, height: min(contentSize.height, gameFrameSize.height))
    }

    private func attributedText(at index: Int) -> AttributedString {
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

    private func colors(for word: String) -> [Color] {
        var colors = Array(repeating: Color.gray.opacity(0.05), count: word.count)
        for (index, value) in word.enumerated() {
            if value.lowercased() == viewModel.word[index].lowercased() && viewModel.matchMap[index] {
                colors[index] = .success.opacity(0.65)
            }
        }
        return colors
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct SizeModifier: ViewModifier {
    private var sizeView: some View {
        GeometryReader { proxy in
            Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
        }
    }

    func body(content: Content) -> some View {
        content.overlay(sizeView)
    }
}

extension View {
    func getSize(perform: @escaping (CGSize) -> ()) -> some View {
        self
            .modifier(SizeModifier())
            .onPreferenceChange(SizePreferenceKey.self) {
                perform($0)
            }
    }
}
