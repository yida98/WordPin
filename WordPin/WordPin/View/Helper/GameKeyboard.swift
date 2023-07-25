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
                        .buttonStyle(KeyboardKey(letter.isLetter ? .primary(size: .headline, emphasis: .medium) : .headline))
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }
}

struct KeyboardKey: ButtonStyle {
    private let width: CGFloat = 26
    private let height: CGFloat = 28
    private let font: Font

    init(_ font: Font) {
        self.font = font
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(font)
            .foregroundColor(configuration.isPressed ? .background : .jade)
            .padding(4)
            .background {
                RoundedRectangle(cornerRadius: width / 4)
                    .stroke(Color.jade, lineWidth: 2)
                    .frame(width: width, height: height)
                    .background {
                        RoundedRectangle(cornerRadius: width / 4)
                            .fill(configuration.isPressed ? Color.jade : Color.clear)
                    }
            }
            .frame(width: width, height: height)
    }
}
