//
//  URLTask.swift
//  WordPin
//
//  Created by Yida Zhang on 7/11/23.
//

import Foundation
import Combine

class URLTask {
    private var urlBase: String = "https://localhost:6060/"
    private var route: String = "submissions/"
    
    func getAllSubmissions() -> AnyPublisher<[Submission], Error> {
        return getSubmissionRequest("")
    }
    
    func getSubmissions(for word: String) -> AnyPublisher<[Submission], Error> {
        return getSubmissionRequest(word)
    }
    
    private func getSubmissionRequest(_ word: String) -> AnyPublisher<[Submission], Error> {
        guard let requestURL = submissionRequestURL(for: word) else {
            return Fail(error: RequestError.InvalidRequestURL).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: requestURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { (data: Data, response: URLResponse) in
                if let response = response as? HTTPURLResponse, response.statusCode == HTTPStatusCode.OK.rawValue {
                    do {
                        let decoder = JSONDecoder()
                        let submission = try decoder.decode([Submission].self, from: data)
                        return submission
                    } catch let error {
                        debugPrint(error.localizedDescription)
                        throw CodingError.JSONDecodingError
                    }
                } else {
                    throw RequestError.InternalServerError
                }
            }
            .map { $0 }
            .eraseToAnyPublisher()
    }
    
    func postSubmission(_ submission: Submission) {
        guard let word = submission.word, let requestURL = submissionRequestURL(for: word) else { return }
        
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
    
    private func submissionRequestURL(for word_id: String) -> URL? {
        guard let encodedURL = word_id.lowercased().encodeUrl() else {
            return nil
        }
        return URL(string: "\(urlBase)\(route)\(encodedURL)")
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
