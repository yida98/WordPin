//
//  GameButton.swift
//  WordPin
//
//  Created by Yida Zhang on 7/13/23.
//

import SwiftUI

struct GameButton: View {
    var body: some View {
        Button {
            debugPrint("lol")
        } label: {
            Text("P L A Y")
                .font(.primary(size: .caption1, emphasis: .bold))
                .foregroundColor(.backgroundFont)
        }.buttonStyle(ExternalPhysicalButton())

    }
}

struct GameButton_Previews: PreviewProvider {
    static var previews: some View {
        GameButton()
    }
}

struct ExternalPhysicalButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 4) {
            configuration.label
            Capsule(style: .continuous)
                .fill(
                    Color.jade
                        .shadow(.inner(color: .white.opacity(0.25), radius: 2, x: 0, y: -1))
                        .shadow(.inner(color: .white.opacity(0.25), radius: 2, x: 0, y: 2))
                        .shadow(.inner(color: .white.opacity(0.3), radius: 0.5, x: 0, y: 2))
                        .shadow(.drop(color: .jadeShadow, radius: 0.5, x: 0, y: 1))
                        .shadow(.drop(color: .white.opacity(0.5), radius: 0.3, x: 0, y: 0.4))
                )
                .frame(width: 54, height: 10)
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.backgroundFont, lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.6))
                    )
        )
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    Color.background
                        .shadow(.drop(color: .backgroundShadow, radius: 4, x: 2, y: 2))
                        .shadow(.drop(color: .white.opacity(0.4), radius: 4, x: -2, y: -2))
                        .shadow(.inner(color: .backgroundShadow, radius: 0.5, x: -1, y: -1))
                        .shadow(.inner(color: .white.opacity(0.4), radius: 0.5, x: 1, y: 1))
                 )
        )
    }
}

