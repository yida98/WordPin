//
//  LeaderboardCell.swift
//  WordPin
//
//  Created by Yida Zhang on 9/13/23.
//

import SwiftUI

struct LeaderboardCell: View {
    let username: String
    let uniqueEntries: Int
    var body: some View {
        HStack {
            Text(username)
            Spacer()
            if uniqueEntries > 1 {
                Text("+\(uniqueEntries)")
            }
        }
    }
}
