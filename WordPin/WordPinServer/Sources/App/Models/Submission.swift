import Fluent
import Vapor

final class Submission: Model, Content {
    static let schema = "submissions"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "user_id")
    var userId: String

    @Field(key: "word")
    var word: String

    @Timestamp(key: "created_at", on: .none)
    var timestamp: Date?

    @Field(key: "group")
    var group: [String]

    @Field(key: "group_count")
    var groupCount: Int

    @Field(key: "display_name")
    var displayName: String

    init() { }

    init(id: UUID? = nil, userId: String, word: String, timestamp: Date?, group: [String], groupCount: Int, displayName: String) {
        self.id = id
        self.userId = userId
        self.word = word
        self.timestamp = timestamp
        self.group = group
        self.groupCount = groupCount
        self.displayName = displayName
    }
}
