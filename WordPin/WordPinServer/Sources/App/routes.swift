import Fluent
import Vapor

func routes(_ app: Application) throws {
//    app.get { req async in
//        "It works!"
//    }
//
//    app.get(":word") { req async -> String in
//        let word = req.parameters.get("word")
//        return "Hello, \(word)!"
//    }
//
//    app.get("leaderboard") { req async -> String in
//        "ok"
//    }
//
//    app.post { req async in
//        "Posting"
//    }

    try app.register(collection: TodoController())
}
