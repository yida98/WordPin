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

    private let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private let jsonDecoder: JSONDecoder = {
        let encoder = JSONDecoder()
        encoder.dateDecodingStrategy = .iso8601
        return encoder
    }()

    private init() { }

    func getDailyWord() async throws -> String {
        guard let requestURL = SubmissionAPI.getDailyWordURL() else { throw RequestError.InvalidRequestURL }

        var urlRequest = URLRequest(url: requestURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        urlRequest.httpMethod = "GET"

        if let (data, response) = try? await URLSession.shared.data(for: urlRequest),
            let response = response as? HTTPURLResponse, response.statusCode == HTTPStatusCode.OK.rawValue {
            do {
                let dailyWord = try jsonDecoder.decode(String.self, from: data)
                return dailyWord
            } catch let error {
                throw error
            }
        }
        throw RequestError.InternalServerError
    }

    func getSubmissions(for word: String) async throws -> [Submission] {
        try await getSubmissionRequest(for: word)
    }

    private func getSubmissionRequest(for word: String) async throws -> [Submission] {
        guard let requestURL = SubmissionAPI.submissionRequestURL(for: word) else {
            throw RequestError.InvalidRequestURL
        }
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = "GET"

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        if let response = response as? HTTPURLResponse,
            response.statusCode == HTTPStatusCode.OK.rawValue {
            do {
                let submission = try jsonDecoder.decode([Submission].self, from: data)
                return submission
            } catch let error {
                throw error
            }
        }
        throw RequestError.InternalServerError
    }
    
    func postSubmission(_ submission: Submission) async throws {
        guard let requestURL = SubmissionAPI.baseURL.url else { return }

        let encodedSubmission = try jsonEncoder.encode(submission)

        var urlRequest = URLRequest(url: requestURL)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = encodedSubmission

        try await URLSession.shared.data(for: urlRequest)
    }

    func nukeSubmissions() {
        guard let requestURL = SubmissionAPI.nukeSubmissionsURL() else { return }

        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: urlRequest)
    }
    
    enum RequestError: Error {
        case InvalidRequestURL
        case InternalServerError
        case NotFound
    }

    /* Feature under reevaluation
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
    */
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
