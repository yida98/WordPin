//
//  LeaderboardCell.swift
//  WordPin
//
//  Created by Yida Zhang on 9/13/23.
//

import SwiftUI

struct LeaderboardCell: View {
    
    let submission: Submission

    var body: some View {
        HStack {
            Text(submission.displayName ?? "Unknown")
                .font(.monospaced(size: .caption1))
                .foregroundColor(.jadeShadow)
            Spacer()
        }
    }
}
