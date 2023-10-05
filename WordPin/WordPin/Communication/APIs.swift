//
//  APIs.swift
//  WordPin
//
//  Created by Yida Zhang on 7/12/23.
//

import Foundation

struct SubmissionAPI {
    private static var scheme: String = "http"
    private static var host: String = "localhost"
    private static var port: Int = 8080
    
    static func submissionRequestURL(for word_id: String) -> URL? {
        guard let encodedWord = word_id.lowercased().encodeUrl() else {
            return nil
        }
        var components = baseURL
        components.path = Route.submissions.rawValue.appending("/\(encodedWord)")

        return components.url
    }

    static func getDailyWordURL() -> URL? {
        var components = baseURL
        components.path = Route.dailyWord.rawValue

        return components.url
    }

    static var baseURL: URLComponents {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.port = port

        return components
    }

    static func nukeSubmissionsURL() -> URL? {
        var components = baseURL
        components.path = Route.erase.rawValue

        return components.url
    }

    enum Route: String {
        case submissions = "/submissions"
        case dailyWord = "/dailyWord"
        case erase = "/erase"
    }
}

struct RandomWordAPI {
    private static var components: URLComponents = {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "random-word-api.herokuapp.com"
        components.path = "/word"
        return components
    }()
    private static var scheme: String = "https"
    private static var host: String = "random-word-api.herokuapp.com"
    private static var route: String = "/word"
    
    static func requestURL(length: Int = 0) -> URL? {
        var urlComponents = RandomWordAPI.components
        if length > 0 {
            urlComponents.queryItems = [URLQueryItem(name: "length", value: String(length))]
        }
        return urlComponents.url
    }
}
