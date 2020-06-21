//
//  PersistenceService.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/22/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import Foundation
import CoreData

class PersistenceService {
    
    private init() {} // Do not allow initilization of the PersistenceService class
    
    // Context is basically a container for all the data you want to save at any given moment
    static var context: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    static var persistentContainerQueue: OperationQueue {
        let containerQueue = OperationQueue()
        containerQueue.maxConcurrentOperationCount = 1
        return containerQueue
    }
    
    // MARK: - Core Data stack
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "NovaOne")
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
        return container
    }()

    // MARK: - Core Data Saving support
    static func saveContext() {
        // Create or update object into CoreData
        persistentContainerQueue.addOperation() {
            let context = self.persistentContainer.viewContext
            if context.hasChanges {
                context.performAndWait {
                    do {
                        try context.save()
                        print("Object saved to CoreData successfully!")
                    } catch {
                        // Replace this implementation with code to handle the error appropriately.
                        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        let nserror = error as NSError
                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                    context.reset() // Reset the context to clean up the cache and low the memory footprint.
                }
            }
        }
    }
    
    // MARK: - Core Data Fetching
    static func fetchEntity<T: NSManagedObject>(_ objectType: T.Type, filter with: NSPredicate?, sort by: [NSSortDescriptor]?) -> [T] {
        
        // Gets filtered objects from an entity type in CoreData
        let entityName = String(describing: objectType)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        // Filter and sort data if needed by using predicates and sort descriptors
        fetchRequest.predicate = with
        fetchRequest.sortDescriptors = by
        
        do {
            let objects = try self.context.fetch(fetchRequest) as? [T]
            return objects ?? [T]()
        } catch {
            print("Error fetching objects: \(error)")
        }
        
        return [T]()
    }
    
    static func fetchCustomerEntity() -> Customer? {
        // Fetches customer data stored in CoreData
        
        let fetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
        do {
            let customer = try self.context.fetch(fetchRequest).first // Returns CoreData objects in an array, so get the first one
            return customer
        } catch {
            fatalError("Failed to fetch Customer CoreData object: \(error)")
        }
    }
    
    static func fetchCount(for entityName: String) -> Int {
        // Gets a count of how many objects a given entity has saved to CoreData
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.includesSubentities = false
        
        var entitiesCount = 0
        
        do {
            entitiesCount = try self.context.count(for: fetchRequest)
        } catch {
            fatalError("Failed to fetch count for CoreData entity: \(error)")
        }
        
        return entitiesCount
    }
    
    static func deleteAllData(for entityName: String) {
        // Deletes ALL data in CoreData for a given entity
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            try self.context.execute(request)
            self.saveContext()
        } catch {
            print("Failed to delete all data for \(entityName): \(error)")
        }
    }
    
}
