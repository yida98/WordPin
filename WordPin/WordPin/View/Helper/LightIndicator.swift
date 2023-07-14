//
//  LightIndicator.swift
//  WordPin
//
//  Created by Yida Zhang on 7/13/23.
//

import SwiftUI

struct LightIndicator: View {
    var on: Bool
    var body: some View {
        Circle()
            .fill(fill().shadow(.inner(color: .primaryFont.opacity(0.35), radius: 1, x: 0.5, y: 0.5)))
            .shadow(color: .primaryFont.opacity(0.35), radius: 1, x: -1, y: -1)
            .shadow(color: .white.opacity(0.5), radius: 1, x: 0.5, y: 0.5)
            .frame(width: 6)
    }
    
    private func fill() -> some ShapeStyle {
        on ? Color.success : Color.failure
    }
}

struct LightIndicator_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            LightIndicator(on: true)
            LightIndicator(on: false)
        }
    }
}
