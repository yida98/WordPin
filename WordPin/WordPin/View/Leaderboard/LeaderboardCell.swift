//
//  LeaderboardCell.swift
//  WordPin
//
//  Created by Yida Zhang on 9/13/23.
//

import SwiftUI

struct LeaderboardCell: View {
    
    let submission: AggregatedLeaderboardSubmission

    var body: some View {
        HStack {
            Text(submission.displayName)
                .font(.monospaced(size: .caption1))
                .foregroundColor(.jadeShadow)
            Spacer()
            Text(submissionsCount())
                .font(.monospaced(size: .caption1, emphasis: .italic))
                .foregroundColor(.success)
        }
    }

    private func submissionsCount() -> String {
        if submission.submissions > 1 {
            return "+\(submission.submissions - 1)"
        }
        return ""
    }
}
