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
            GameClock(count: $viewModel.wordCount, globalHighScore: 5)
                .padding(.horizontal, 20)
            Spacer()
            HStack(spacing: letterSpacing()) {
                ForEach(0..<viewModel.word.count, id: \.self) { wordIndex in
                    VStack(spacing: 0) {
                        Text(String(viewModel.word[viewModel.word.index(viewModel.word.startIndex, offsetBy: wordIndex)]).uppercased())
                            .titleText(.title2)
                            .minimumScaleFactor(0.8)
                        LightIndicator(on: wordIndex % 3 == 0)
                    }.frame(width: letterWidth())
                }
            }
            VStack(spacing: 20) {
                VStack {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(0..<3) { index in
                                HStack(spacing: letterSpacing()) {
                                    ForEach(0..<viewModel.word.count, id: \.self) { wordIndex in
                                        VStack(spacing: 0) {
                                            Text(String(viewModel.word[viewModel.word.index(viewModel.word.startIndex, offsetBy: wordIndex)]).uppercased())
                                                .digitalText()
                                                .foregroundColor(.primaryFont)
                                                .minimumScaleFactor(0.8)
                                        }.frame(width: letterWidth())
                                    }
                                }
                            }
                        }
                    }
                    Divider()
                    HStack(spacing: letterSpacing()) {
                        ForEach(0..<viewModel.word.count, id: \.self) { wordIndex in
                            VStack(spacing: 4) {
                                Text(input(at: wordIndex))
                                    .digitalText()
                                    .foregroundColor(.primaryFont)
                                    .minimumScaleFactor(0.8)
                                Rectangle()
                                    .fill(Color.secondaryFont)
                                    .frame(width: letterWidth(), height: 1)
                            }
                            .frame(width: letterWidth())
                        }
                    }
                }
                .padding(10)
                .padding(.horizontal, 10)
                .frame(width: gameFrameSize().width, height: gameFrameSize().height)
                .fixedSize()
                .neumorphicScreen {
                    RoundedRectangle(cornerRadius: 20)
                }
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
        let height = Constant.screenBounds.height / 3
        return CGSize(width: width, height: height)
    }
    
    private func letterWidth() -> CGFloat {
        
        return 16.0
    }
    
    private func letterSpacing() -> CGFloat {
        
        return 16.0
    }
    
    private func totalInputLength() -> CGFloat {
        CGFloat(viewModel.word.count) * (letterWidth() + letterSpacing()) - letterSpacing()
    }

    private func input(at index: Int) -> String {
        if index < input.count {
            return String(input[index])
        }
        return " "
    }
}

struct DigitalText: ViewModifier {
    let size: UIFont.TextStyle
    func body(content: Content) -> some View {
        content
            .textShadow()
            .font(.digitalFont(size: size))
    }
}

extension Text {
    func digitalText(_ size: UIFont.TextStyle = .title2) -> some View {
        modifier(DigitalText(size: size))
    }
}
