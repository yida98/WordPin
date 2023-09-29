import Fluent

struct CreateSubmission: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("submissions")
            .id()
            .field("user_id", .string, .required)
            .field("word", .string, .required)
            .field("created_at", .datetime)
            .field("group", .array(of: .string), .required)
            .field("group_count", .int16, .required)
            .field("display_name", .string, .required)
            .unique(on: "user_id", "group")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("submissions").delete()
    }
}
