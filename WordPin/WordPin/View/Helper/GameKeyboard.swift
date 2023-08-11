//
//  GameKeyboard.swift
//  WordPin
//
//  Created by Yida Zhang on 7/23/23.
//

import SwiftUI

struct GameKeyboard: View {
    @Binding var key: Character?
    private let keys: [[Character]] =
      [["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
       ["A", "S", "D", "F", "G", "H", "J", "K", "L", "⌫"],
       ["Z", "X", "C", "V", "B", "N", "M", "⏎"]]

    init(key: Binding<Character?>) {
        self._key = key
    }

    var body: some View {
        VStack {
            ForEach(keys, id: \.self) { letters in
                HStack {
                    Spacer(minLength: 0)
                    ForEach(letters, id: \.self) { letter in
                        Button(String(letter)) {
                            key = letter
                        }
                        .buttonStyle(KeyboardKey(letter.isLetter ? .primary(size: .title2, emphasis: .medium) : .headline))
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }
}

struct KeyboardKey: ButtonStyle {
    private let width: CGFloat
    private let height: CGFloat
    private let font: Font

    init(_ font: Font) {
        let width = (Constant.screenBounds.width / 10) - 10
        self.width = width
        self.height = width + 2
        self.font = font
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(font)
            .foregroundColor(configuration.isPressed ? .background : .jade)
            .padding(4)
            .background {
                RoundedRectangle(cornerRadius: width / 4)
                    .fill(Color.jade.opacity(0.2))
                    .frame(width: width, height: height)
            }
            .frame(width: width, height: height)
    }
}
