//
//  PlayerHistoryCell.swift
//  WordPin
//
//  Created by Yida Zhang on 10/2/23.
//

import SwiftUI

struct PlayerHistoryCell: View {
    let history: HistoryCellData

    var body: some View {
        HStack {
            Text(history.word)
                .font(.secondaryFont(size: .title2))
                .foregroundColor(.secondaryFont)
            Spacer(minLength: 0)
            Text(String(history.record))
                .font(.secondaryFont(size: .title2))
                .foregroundColor(.jade)
        }
    }
}

struct PlayerHistoryCell_Previews: PreviewProvider {
    static var previews: some View {
        PlayerHistoryCell(history: HistoryCellData(word: "lmao", record: 2))
    }
}
