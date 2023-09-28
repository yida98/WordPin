import Fluent

struct CreateHistory: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("dailyWords")
            .id()
            .field("dailyWord", .string, .required)
            .field("date", .double, .required)
            .unique(on: "dailyWord")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("dailyWords").delete()
    }
}

