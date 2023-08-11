//
//  ContiguousRectangles.swift
//  WordPin
//
//  Created by Yida Zhang on 8/10/23.
//

import SwiftUI

struct ContiguousRectangles: View {
    let count: Int
    let spacing: CGFloat
    let cornerRadius: CGFloat
    let style: RoundedCornerStyle
    let colors: [Color]

    init(count: Int, spacing: CGFloat = 10, cornerRadius: CGFloat = 0, style: RoundedCornerStyle = .continuous, colors: [Color] = [.black]) {
        self.count = count
        self.spacing = spacing
        self.cornerRadius = cornerRadius
        self.style = style
        self.colors = colors
    }

    var body: some View {
        GeometryReader { geometryProxy in
            HStack {
                Spacer(minLength: 0)
                HStack(spacing: spacing) {
                    ForEach(0..<count, id: \.self) { index in
                        RoundedRectangle(cornerRadius: cornerRadius, style: style)
                            .fill(color(at: index))
                    }
                }
                .frame(width: geometryProxy.size.width - spacing)
                Spacer(minLength: 0)
            }
            .frame(width: geometryProxy.size.width)
        }
    }

    private func color(at index: Int) -> Color {
        let (_, remainder) = index.quotientAndRemainder(dividingBy: colors.count)
        return colors[remainder]
    }
}
