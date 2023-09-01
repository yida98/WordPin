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
            ZStack {
                VStack {
                    // Heading banner
                    HStack {
                        Text("Word")
                            .font(.secondaryFont(size: .headline))
                            .foregroundColor(.secondaryFont)
                        Spacer()
                        Image(systemName: "star.fill")
                            .frame(width: scoreWidth)
                            .foregroundColor(.secondaryFont)
                        Image(systemName: "globe.americas.fill")
                            .frame(width: scoreWidth)
                            .foregroundColor(.secondaryFont)
                    }
                    SubmissionsTable(viewModel: viewModel)
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
            .scenePadding(.minimum, edges: .horizontal)
            
            HStack {
                Spacer()
                Button {
                    viewModel.playNewGame()
                } label: {
                    Text("Play")
                }
            }
            .padding(.trailing, 20)
            .scenePadding(.minimum, edges: .horizontal)
            .scenePadding(.minimum, edges: .bottom)
        }
        .background(Color.background)
        .sheet(isPresented: $viewModel.isPresentingGame) {
            // TODO: On dismiss
            viewModel.finishedGame()
        } content: {
            if let currentGame = viewModel.currentGame {
                GameView(viewModel: currentGame)
            } else {
                // TODO: Error page
                EmptyView()
            }
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
            .font(.primary(size: size, emphasis: .medium))
            .foregroundColor(.white)
    }
}
