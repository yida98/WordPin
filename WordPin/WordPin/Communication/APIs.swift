//
//  APIs.swift
//  WordPin
//
//  Created by Yida Zhang on 7/12/23.
//

import Foundation

struct SubmissionAPI {
    private static var urlBase: String = "https://localhost:6060/"
    private static var route: String = "submissions/"
    
    static func submissionRequestURL(for word_id: String) -> URL? {
        guard let encodedURL = word_id.lowercased().encodeUrl() else {
            return nil
        }
        return URL(string: "\(urlBase)\(route)\(encodedURL)")
    }
}

struct RandomWordAPI {
    private static var urlBase: String = "https://random-word-api.herokuapp.com/"
    private static var route: String = "word"
    
    static func requestURL(length: Int = 0) -> URL? {
        return URL(string: "\(urlBase)\(route)\(length == 0 ? "" : "?length=\(length)")")
    }
}
