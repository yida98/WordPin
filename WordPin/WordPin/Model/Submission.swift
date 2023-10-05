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
        case id, word, group, timestamp, displayName, groupCount, userId
    }
    
    // MARK: - Core Data Managed Object
    @NSManaged var id: UUID?
    @NSManaged var word: String?
    @NSManaged var group: [String]?
    @NSManaged var timestamp: Date?
    @NSManaged var displayName: String?
    @NSManaged var groupCount: Int32 // Values can be nil until the model is saved
    @NSManaged var userId: String?
    
    public required convenience init(from decoder: Decoder) throws {
        let managedObjectContext = PersistenceController.shared.container.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Submission", in: managedObjectContext) else {
            fatalError("Failed to decode Submission")
        }
        
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id)
        self.word = try container.decodeIfPresent(String.self, forKey: .word)
        self.group = try container.decodeIfPresent([String].self, forKey: .group)
        self.timestamp = try container.decodeIfPresent(Date.self, forKey: .timestamp)
        self.displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
        self.groupCount = try container.decode(Int32.self, forKey: .groupCount)
        self.userId = try container.decodeIfPresent(String.self, forKey: .userId)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(word, forKey: .word)
        try container.encodeIfPresent(group, forKey: .group)
        try container.encodeIfPresent(timestamp, forKey: .timestamp)
        try container.encodeIfPresent(displayName, forKey: .displayName)
        try container.encode(groupCount, forKey: .groupCount)
        try container.encodeIfPresent(userId, forKey: .userId)
    }
}

public extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}
