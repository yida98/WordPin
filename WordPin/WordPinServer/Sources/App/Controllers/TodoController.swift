import Fluent
import Vapor

struct TodoController: RouteCollection {
    static let startingDate: Date = Calendar(identifier: .gregorian).date(from: DateComponents(timeZone: .autoupdatingCurrent, year: 2023, month: 9, day: 21)) ?? .now
    static let wordList: [String]? = {
        if let resourcePath = Bundle.module.path(forResource: "wordList", ofType: "txt") {
            do {
                let text = try String(contentsOfFile: resourcePath, encoding: .utf8)
                let lines = text.components(separatedBy: .newlines)
                return lines
            } catch(let error) {
                return nil
            }
        }
        return nil
    }()
    
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: index)
        routes.get("dailyWord", use: getDailyWord)
        routes.get("history", use: getDailyWords)

        let submissions = routes.grouped("submissions")
        submissions.get(use: getSubmissions)
        submissions.get(":word", use: getWord)
        submissions.post(use: create)
        submissions.group(":todoID") { todo in
            todo.delete(use: delete)
        }
    }

    func index(req: Request) async throws -> [Todo] {
        try await Todo.query(on: req.db).all()
    }

    func getSubmissions(req: Request) async throws -> String {
        getDailyWord(for: .now) ?? " "
    }

    func getWord(req: Request) async throws -> [Todo] {
        guard let word = req.parameters.get("word") else { return [] }
        return try await Todo.query(on: req.db)
            .filter(\.$word == word)
            .all()
    }

    func getDailyWord(req: Request) async throws -> String {
        let dailyWord = getDailyWord(for: .now)
        Task(priority: .background) {
            if let todaysWord = dailyWord {
                let dailyWord = DailyWord(dailyWord: todaysWord, date: .now)
                try await dailyWord.save(on: req.db)
            }
        }
        return dailyWord ?? " "
    }

    func getDailyWords(req: Request) async throws -> [DailyWord] {
        try await DailyWord.query(on: req.db).all()
    }

    func create(req: Request) async throws -> Todo {
        let todo = try req.content.decode(Todo.self)
        try await todo.save(on: req.db)
        return todo
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let todo = try await Todo.find(req.parameters.get("todoID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await todo.delete(on: req.db)
        return .noContent
    }

    func getDailyWord(for date: Date) -> String? {
        let wordIndex = Calendar(identifier: .gregorian).numberOfDaysBetween(TodoController.startingDate, and: date)

        guard let wordList = TodoController.wordList, wordIndex < wordList.count else { return nil }
        return wordList[wordIndex]
    }
}

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)

        return numberOfDays.day!
    }
}
