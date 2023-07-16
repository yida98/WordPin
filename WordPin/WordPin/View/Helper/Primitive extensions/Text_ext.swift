//
//  Text_ext.swift
//  WordPin
//
//  Created by Yida Zhang on 7/15/23.
//

import Foundation
import SwiftUI

extension View {
    func textShadow() -> some View {
        modifier(ShadowedText())
    }
    
    func textEngravement() -> some View {
        modifier(EngravedText())
    }
}

struct ShadowedText: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            content
                .foregroundColor(.primaryFont.opacity(0.25))
                .offset(x: 1, y: 1)
            content
        }
    }
}

struct EngravedText: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            content
                .foregroundColor(.primaryFont.opacity(0.5))
                .offset(x: -0.5, y: -0.5)
            content
                .foregroundColor(.white.opacity(0.5))
                .offset(x: 1, y: 1)
            content
        }
    }
}
