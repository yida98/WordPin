//
//  Submission.swift
//  WordPin
//
//  Created by Yida Zhang on 7/12/23.
//

import Foundation
import CoreData

@objc(Submission)
class Submission: NSManagedObject, Codable {
    enum CodingKeys: String, CodingKey {
        case id, word, group, timestamp
    }
    
    // MARK: - Core Data Managed Object
    @NSManaged var id: UUID?
    @NSManaged var word: String?
    @NSManaged var group: [String]?
    @NSManaged var timestamp: Date?
    
    public required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Submission", in: managedObjectContext) else {
            fatalError("Failed to decode Submission")
        }
        
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.word = try container.decode(String.self, forKey: .word)
        self.group = try container.decode([String].self, forKey: .group)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(word, forKey: .word)
        try container.encode(group, forKey: .group)
        try container.encode(timestamp, forKey: .timestamp)
    }
}

public extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}
