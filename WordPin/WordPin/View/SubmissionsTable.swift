//
//  SubmissionsTable.swift
//  WordPin
//
//  Created by Yida Zhang on 7/13/23.
//

import SwiftUI

struct SubmissionsTable: View {
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                ForEach(0..<10) { i in
                    HStack {
                        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                            .gameText()
                        Spacer()
                        Text("7752")
                            .gameText()
                            .minimumScaleFactor(0.5)
                            .frame(width: 50)
                        Text("6862")
                            .gameText()
                            .minimumScaleFactor(0.5)
                            .frame(width: 50)
                    }
                }
            }
        }
    }
}

struct SubmissionsTable_Previews: PreviewProvider {
    static var previews: some View {
        SubmissionsTable()
    }
}

extension Text {
    func gameText(_ size: UIFont.TextStyle = .title3) -> some View {
        modifier(GameText(size: size))
    }
}

struct GameText: ViewModifier {
    let size: UIFont.TextStyle
    
    func body(content: Content) -> some View {
        content
            .font(.secondaryFont(size: size))
            .foregroundColor(.primaryFont)
            .shadow(color: .primaryFont.opacity(0.25), radius: 1, x: 1, y: 1)
    }
}
