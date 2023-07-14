//
//  WordCollectionView.swift
//  WordPin
//
//  Created by Yida Zhang on 7/7/23.
//

import SwiftUI

struct WordCollectionView: View {
    
    private let scoreWidth: CGFloat = 50
    
    private let titleWidth: CGFloat = 20
    private let title: String = "WORDPIN"
    
    var body: some View {
        VStack {
            // Title
            HStack {
                ForEach(0..<7) { index in
                    VStack(spacing: 0) {
                        Text(String(title[title.index(title.startIndex, offsetBy: index)]))
                            .titleText(.title2)
                        LightIndicator(on: index % 3 == 0)
                    }.frame(width: titleWidth)
                }
            }
            ZStack {
                VStack {
                    // Heading banner
                    HStack {
                        Text("Word")
                            .font(.digitalFont(size: .headline))
                            .foregroundColor(.secondaryFont)
                            .shadow(color: .primaryFont.opacity(0.25), radius: 1, x: 1, y: 1)
                        Spacer()
                        Image(systemName: "star.fill")
                            .frame(width: scoreWidth)
                            .foregroundColor(.secondaryFont)
                            .shadow(color: .primaryFont.opacity(0.25), radius: 1, x: 1, y: 1)
                        Image(systemName: "globe.americas.fill")
                            .frame(width: scoreWidth)
                            .foregroundColor(.secondaryFont)
                            .shadow(color: .primaryFont.opacity(0.25), radius: 1, x: 1, y: 1)
                    }
                    SubmissionsTable()
                }.padding(.top, 6)
                HStack {
                    Spacer()
                    Rectangle()
                        .fill(.black.opacity(0.15))
                        .frame(width: scoreWidth)
                }
            }
            .padding(20)
            .padding(.horizontal, 10)
            .neumorphicScreen {
                RoundedRectangle(cornerRadius: 10)
            }
            .scenePadding(.minimum, edges: .horizontal)
            
            HStack {
                Spacer()
                GameButton()
            }
            .padding(.trailing, 20)
            .scenePadding(.minimum, edges: .horizontal)
            .scenePadding(.minimum, edges: .bottom)
        }
        .background(Color.background)
    }
}

struct WordCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        WordCollectionView()
    }
}

extension Text {
    func titleText(_ size: UIFont.TextStyle = .body) -> some View {
        modifier(TitleText(size: size))
    }
}

struct TitleText: ViewModifier {
    let size: UIFont.TextStyle
    
    func body(content: Content) -> some View {
        content
            .font(.primary(size: size, emphasis: .medium))
            .foregroundColor(.screenFont)
            .shadow(color: .black.opacity(0.5), radius: 0.5, x: -0.5, y: -0.5)
            .shadow(color: .white.opacity(0.5), radius: 1, x: 1, y: 1)
    }
}
