import Fluent
import Vapor
import Foundation

final class DailyWord: Model, Content {
    static let schema = "dailyWords"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "dailyWord")
    var dailyWord: String

    /// Epoch time
    @Field(key: "date")
    var date: Double

    init() { }

    init(id: UUID? = nil, dailyWord: String, date: Date) {
        self.id = id
        self.dailyWord = dailyWord
        self.date = date.epochTime
    }
}

extension Date {
    var epochTime: TimeInterval {
        floor(timeIntervalSince1970 / (24.0 * 60.0 * 60.0)) * 24.0 * 60.0 * 60.0
    }
}
