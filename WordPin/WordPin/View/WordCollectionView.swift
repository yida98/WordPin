//
//  WordCollectionView.swift
//  WordPin
//
//  Created by Yida Zhang on 7/7/23.
//

import SwiftUI

struct WordCollectionView: View {
    @ObservedObject var viewModel: WordCollectionViewModel
    
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
                            .textShadow()
                            .font(.digitalFont(size: .headline))
                            .foregroundColor(.secondaryFont)
                        Spacer()
                        Image(systemName: "star.fill")
                            .textShadow()
                            .frame(width: scoreWidth)
                            .foregroundColor(.secondaryFont)
                        Image(systemName: "globe.americas.fill")
                            .textShadow()
                            .frame(width: scoreWidth)
                            .foregroundColor(.secondaryFont)
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
                GameButton {
                    viewModel.playNewGame()
                }
            }
            .padding(.trailing, 20)
            .scenePadding(.minimum, edges: .horizontal)
            .scenePadding(.minimum, edges: .bottom)
        }
        .background(Color.background)
        .sheet(isPresented: $viewModel.isPresentingGame) {
            // TODO: On dismiss
        } content: {
            GameView(viewModel: viewModel.makeNewGame())
        }
    }
}

struct WordCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        WordCollectionView(viewModel: WordCollectionViewModel())
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
            .textEngravement()
            .font(.primary(size: size, emphasis: .medium))
            .foregroundColor(.screenFont)
//            .shadow(color: .black.opacity(0.5), radius: 0.5, x: -0.5, y: -0.5)
//            .shadow(color: .white.opacity(0.5), radius: 1, x: 1, y: 1)
    }
}
