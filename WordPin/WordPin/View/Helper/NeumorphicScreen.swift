//
//  NeumorphicScreen.swift
//  WordPin
//
//  Created by Yida Zhang on 7/13/23.
//

import Foundation
import SwiftUI

struct NeumorphicScreen<S: Shape>: ViewModifier {
    private let shape: S
    
    init(_ shape: () -> S) {
        self.shape = shape()
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                shape
                    .fill(Color.screenBackground.shadow(.inner(color: .primaryFont.opacity(0.25), radius: 1, x: 1, y: 1)))
                    .shadow(color: .primaryFont.opacity(0.25), radius: 1, x: -1, y: -1)
                    .shadow(color: .white.opacity(0.5), radius: 2, x: 2, y: 2)
            )
    }
}

extension View {
    func neumorphicScreen<S: Shape>(_ shape: () -> S) -> some View {
        modifier(NeumorphicScreen(shape))
    }
}
