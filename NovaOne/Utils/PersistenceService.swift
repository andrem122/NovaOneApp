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
    static func saveContext () {
        // Create or update object into CoreData
        let context = self.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("Object saved to CoreData successfully!")
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    static func fetchEntities<Object: NSManagedObject>(entity: Object) -> [Object] {
        // Get an object stored in CoreData by an entity type and return it
        
        if let fetchRequest: NSFetchRequest<Object> = Object.fetchRequest() as? NSFetchRequest<Object> {
            do {
                let coreDataobjects = try PersistenceService.context.fetch(fetchRequest) // Returns CoreData objects in an array
                return coreDataobjects
            } catch {
                fatalError("Failed to fetch CoreData objects: \(error)")
            }
        }
        
        // Return empty array of an Object instance if we cannot get the CoreData object
        let coreDataobjects = [Object()]
        return coreDataobjects
    }
    
    static func fetchEntitiesByAttribute<Object: NSManagedObject>(entity: Object, attribute: String, attributeValue: String) -> [Object] {
        // Get CoreData objects by a attribute (column name in a database table) and attributeValue (column value in a database table)
        // (like querying a database)
        
        if let fetchRequest: NSFetchRequest<Object> = Object.fetchRequest() as? NSFetchRequest<Object> {
            fetchRequest.predicate = NSPredicate(format: "\(attribute) == %@", attributeValue)
            do {
                let coreDataobjects = try PersistenceService.context.fetch(fetchRequest) // Returns CoreData objects in an array
                return coreDataobjects
            } catch {
                fatalError("Failed to fetch CoreData objects: \(error)")
            }
        }
        
        // Return empty array of an Object instance if we cannot get the CoreData object
        let coreDataobjects = [Object()]
        return coreDataobjects
    }
    
}
