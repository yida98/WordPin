//
//  Persistence.swift
//  WordPin
//
//  Created by Yida Zhang on 7/7/23.
//

import CoreData

class PersistenceController: ObservableObject {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Submission(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "WordPin")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    private lazy var submissionEntity: NSEntityDescription? = {
        let managedContext = container.viewContext
        return NSEntityDescription.entity(forEntityName: EntityName.submission.rawValue, in: managedContext)
    }()
    
    enum EntityName: String, CaseIterable {
        typealias RawValue = String
        case submission = "Submission"
    }
    
    func fetchAll() -> [NSManagedObject]? {
        let sortDescriptors = [NSSortDescriptor(key: "word", ascending: true)]
        let results = fetch(entity: .submission, sortDescriptors: sortDescriptors)
        switch results {
        case .success(let objects):
            return objects as? [Submission]
        default:
            return nil
        }
    }
    
    /// Returns all of the submissions for the word which acts as its history in descending order by creation date
    func fetchOne(_ word: String) -> [Submission]? {
        let predicate = NSPredicate(format: "word == %@", word)
        let sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        let results = fetch(entity: .submission, with: predicate, sortDescriptors: sortDescriptors)
        switch results {
        case .success(let objects):
            return objects as? [Submission]
        default:
            return nil
        }
    }
    
    private func fetch(entity: EntityName, with predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> Result<[NSManagedObject]?, Error> {
        let managedContext = container.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            return .success(results)
        } catch let error {
            return .failure(error)
        }
    }
    
    // MARK: - Save
    
    func save(word: String, group: [String]) -> NSManagedObject? {
        guard let entityObject = submissionEntity else { debugPrint("Could not get submissionEntity"); return nil }
        let context = container.viewContext
        let entity = NSManagedObject(entity: entityObject, insertInto: context)
        
        entity.setValue(UUID(), forKey: Submission.Keys.id.rawValue)
        entity.setValue(group, forKey: Submission.Keys.group.rawValue)
        entity.setValue(word, forKey: Submission.Keys.word.rawValue)
        entity.setValue(Date(), forKey: Submission.Keys.timestamp.rawValue)
        
        saveContext()

        return entity
    }
    
    private func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // TODO: Handle error
                debugPrint("Unable to save due to \(error)")
            }
        }
        self.objectWillChange.send()
    }
}

extension Submission {
    enum Keys: String {
        case id, userId, timestamp, word, group
    }
}
