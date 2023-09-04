//
//  URLTask.swift
//  WordPin
//
//  Created by Yida Zhang on 7/11/23.
//

import Foundation
import Combine

class URLTask {
    static let shared = URLTask()

    private init() { }

    func getNewWord(length: Int = 0) async throws -> [String] {
        // TODO: Find valid word
        guard let requestURL = RandomWordAPI.requestURL(length: length) else {
            throw RequestError.InvalidRequestURL
        }

        var urlRequest = URLRequest(url: requestURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        urlRequest.httpMethod = "GET"

        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        return try JSONDecoder().decode([String].self, from: data)
    }

    func getRandomWord(length: Int = 0) -> AnyPublisher<[String], Error> {
        guard let requestURL = RandomWordAPI.requestURL(length: length) else {
            return Fail(error: RequestError.InvalidRequestURL).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: requestURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        urlRequest.httpMethod = "GET"

        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { (data: Data, response: URLResponse) in
                if let response = response as? HTTPURLResponse, response.statusCode == HTTPStatusCode.OK.rawValue {
                    do {
                        let decoder = JSONDecoder()
                        let newWord = try decoder.decode([String].self, from: data)
                        return newWord
                    } catch let error {
                        debugPrint(error.localizedDescription)
                        throw CodingError.JSONDecodingError
                    }
                } else {
                    throw RequestError.InternalServerError
                }
            }
            .eraseToAnyPublisher()
    }

    func getAllSubmissions() async -> Result<[Submission], Error> {
        return await getSubmissionRequest(for: "")
    }

    func getSubmissions(for word: String) async -> Result<[Submission], Error> {
        return await getSubmissionRequest(for: word)
    }

    private func getSubmissionRequest(for word: String) async -> Result<[Submission], Error> {
        guard let requestURL = SubmissionAPI.submissionRequestURL(for: word) else {
            return .failure(RequestError.InvalidRequestURL)
        }
        var urlRequest = URLRequest(url: requestURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        urlRequest.httpMethod = "GET"

        if let (data, response) = try? await URLSession.shared.data(for: urlRequest),
            let response = response as? HTTPURLResponse,
            response.statusCode == HTTPStatusCode.OK.rawValue {
            do {
                let submission = try JSONDecoder().decode([Submission].self, from: data)
                return .success(submission)
            } catch let error {
                return .failure(error)
            }
        } else {
            return .failure(RequestError.InternalServerError)
        }
    }
    
    func postSubmission(_ submission: Submission) {
        guard let word = submission.word, let requestURL = SubmissionAPI.submissionRequestURL(for: word) else { return }
        
        let json: [String: Any] = ["id": submission.id?.uuidString as Any,
                                   "userId": "WA?", // TODO: UserID
                                   "word": submission.word as Any,
                                   "group": submission.group as Any,
                                   "timestamp": submission.timestamp as Any]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = jsonData
        
        URLSession.shared.dataTask(with: urlRequest)
    }
    
    enum RequestError: Error {
        case InvalidRequestURL
        case InternalServerError
        case NotFound
    }
}

extension String {
    func encodeUrl() -> String? {
        return self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    }
    
    func decodeUrl() -> String? {
        return self.removingPercentEncoding
    }
}

enum HTTPStatusCode: Int {
    case OK = 200
    case NotFound = 404
    case InternalServerError = 500
}

enum CodingError: Error {
    case JSONDecodingError
}
