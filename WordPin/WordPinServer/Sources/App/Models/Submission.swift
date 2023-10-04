import Fluent
import Vapor

final class Submission: Model, Content {
    static let schema = "submissions"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "word")
    var word: String

    @Field(key: "group")
    var group: [String]

    @Timestamp(key: "created_at", on: .none)
    var timestamp: Date?

    @Field(key: "display_name")
    var displayName: String

    @Field(key: "group_count")
    var groupCount: Int32

    @Field(key: "user_id")
    var userId: String

    init() { }

    init(id: UUID? = nil, userId: String, word: String, timestamp: Date?, group: [String], groupCount: Int32, displayName: String) {
        self.id = id
        self.userId = userId
        self.word = word
        self.timestamp = timestamp
        self.group = group
        self.groupCount = groupCount
        self.displayName = displayName
    }
}
