//
//  GameClock.swift
//  WordPin
//
//  Created by Yida Zhang on 7/24/23.
//

import SwiftUI

struct GameClock: View {
    @Binding var count: Int
    let globalHighScore: Int

    @State var startTime: Date = .now
    @State var timeElapsed: Int = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack {
            Spacer()
            HStack {
                Text(timeString())
                    .digitalText()
                    .foregroundColor(.primaryFont)
                    .onReceive(timer) { firedDate in
                        timeElapsed = Int(firedDate.timeIntervalSince(startTime))
                    }
                Divider()
                Text(String(count))
                    .digitalText()
                    .foregroundColor(.primaryFont)
                Divider()
                Text(String(globalHighScore))
                    .digitalText()
                    .foregroundColor(.tertiaryFont)
            }
            .padding(5)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.1))
                    )
            )
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func timeString() -> String {
        let (minute, second) = timeElapsed.quotientAndRemainder(dividingBy: 60)
        return "\(minute):\(String(format: "%02d", second))"
    }
}
