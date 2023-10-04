import Fluent
import Vapor

struct WPServerController: RouteCollection {
    static let startingDate: Date = Calendar(identifier: .gregorian).date(from: DateComponents(timeZone: .autoupdatingCurrent, year: 2023, month: 9, day: 21)) ?? Date()
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

    let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    let jsonDecoder: JSONDecoder = {
        let encoder = JSONDecoder()
        encoder.dateDecodingStrategy = .iso8601
        return encoder
    }()
    
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: index)
        routes.get("dailyWord", use: getDailyWord)
        routes.get("history", use: getDailyWords)
        routes.delete("erase", use: nuke)

        let submissions = routes.grouped("submissions")
        submissions.get(use: getSubmissions)
        submissions.get(":word", use: getWord)
        submissions.post(use: create)
        submissions.group(":todoID") { todo in
            todo.delete(use: delete)
        }
    }

    /// returns `[Submission]` encoded by `JSON`
    func index(req: Request) async throws -> Data {
        try jsonEncoder.encode(try await Submission.query(on: req.db).all())
    }

    /// returns `[Submission]` encoded by `JSON`
    func getSubmissions(req: Request) async throws -> Data {
        try jsonEncoder.encode(getDailyWord(for: Date()))
    }

    /// returns `[Submission]` encoded by `JSON`
    func getWord(req: Request) async throws -> Data {
        guard let word = req.parameters.get("word"),
                let minimum = try? await Submission.query(on: req.db).filter(\.$word == word).min(\.$groupCount) else {
            return try jsonEncoder.encode([Submission]())
        }
        let submissions = try await Submission.query(on: req.db)
            .filter(\.$word == word)
            .filter(\.$groupCount == minimum)
            .all()
        return try jsonEncoder.encode(submissions)
    }

    /// returns `String` encoded by `JSON`
    func getDailyWord(req: Request) async throws -> Data {
        let dailyWord = getDailyWord(for: Date())
        Task(priority: .background) {
            if let todaysWord = dailyWord {
                let dailyWord = DailyWord(dailyWord: todaysWord, date: Date())
                try await dailyWord.save(on: req.db)
            }
        }
        return try jsonEncoder.encode(dailyWord)
    }

    /// returns `[DailyWord]` encoded by `JSON`
    func getDailyWords(req: Request) async throws -> Data {
        try jsonEncoder.encode(try await DailyWord.query(on: req.db).all())
    }

    func create(req: Request) async throws -> Submission {
        guard let byteBuffer = req.body.data else { throw Abort(.badRequest) }
        let submission = try jsonDecoder.decode(Submission.self, from: byteBuffer)
//        let submission = try req.content.decode(Submission.self)
        try await submission.save(on: req.db)
        return submission
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let submission = try await Submission.find(req.parameters.get("todoID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await submission.delete(on: req.db)
        return .noContent
    }

    func nuke(req: Request) async throws -> HTTPStatus {
        try await Submission.query(on: req.db).delete()
        return .noContent
    }

    func getDailyWord(for date: Date) -> String? {
        let wordIndex = Calendar(identifier: .gregorian).numberOfDaysBetween(WPServerController.startingDate, and: date)

        guard let wordList = WPServerController.wordList, wordIndex < wordList.count else { return nil }
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

extension Data: AsyncResponseEncodable {
    public func encodeResponse(for request: Vapor.Request) async throws -> Vapor.Response {
        var response = Response(status: .ok)
        response.headers.contentType = .plainText
        response.body = .init(data: self)
        return response
    }
}
