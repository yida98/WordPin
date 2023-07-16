//
//  GameView.swift
//  WordPin
//
//  Created by Yida Zhang on 7/13/23.
//

import SwiftUI

struct GameView: View {
    @State var input: String = ""
    let word: String
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                HStack {
                    Text("175:53")
                        .digitalText()
                        .foregroundColor(.primaryFont)
                    Divider()
                    Text("3")
                        .digitalText()
                        .foregroundColor(.primaryFont)
                    Divider()
                    Text("2")
                        .digitalText()
                        .foregroundColor(.tertiaryFont)
                }
                .padding(5)
                .padding(.horizontal, 4)
                .neumorphicScreen {
                    RoundedRectangle(cornerRadius: 10)
                }
                .fixedSize()
            }.padding(.horizontal, 20)
            Spacer()
            HStack(spacing: letterSpacing()) {
                ForEach(0..<word.count, id: \.self) { wordIndex in
                    VStack(spacing: 0) {
                        Text(String(word[word.index(word.startIndex, offsetBy: wordIndex)]).uppercased())
                            .titleText(.title2)
                            .minimumScaleFactor(0.8)
                        LightIndicator(on: wordIndex % 3 == 0)
                    }.frame(width: letterWidth())
                }
            }
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(0..<3) { index in
                            HStack(spacing: letterSpacing()) {
                                ForEach(0..<word.count, id: \.self) { wordIndex in
                                    VStack(spacing: 0) {
                                        Text(String(word[word.index(word.startIndex, offsetBy: wordIndex)]).uppercased())
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
                    ForEach(0..<word.count, id: \.self) { wordIndex in
                        VStack(spacing: 4) {
                            Text("B")
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
            Spacer()
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
        CGFloat(word.count) * (letterWidth() + letterSpacing()) - letterSpacing()
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(word: "biggest")
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
