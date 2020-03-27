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
    
    static func fetchCustomerEntity() -> Customer? {
        // Fetches customer data stored in CoreData
        
        let fetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
        do {
            let customer = try PersistenceService.context.fetch(fetchRequest).first // Returns CoreData objects in an array, so get the first one
            return customer
        } catch {
            fatalError("Failed to fetch Customer CoreData object: \(error)")
        }
    }
    
    static func fetchCustomerCompanies() -> [Any]? {
        // Fetches all company entities stored in CoreData filtered by customer
        
        let fetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
        do {
            let customer = try PersistenceService.context.fetch(fetchRequest).first // Returns customer object
            return customer?.companies?.allObjects // return as an Array type instead of NSSet
        } catch {
            fatalError("Failed to fetch CoreData company objects: \(error)")
        }
    }
    
    static func customerHasCompanies() -> Bool {
        // Checks whether or not a customer has companies in the CoreData database
        let fetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
        do {
            guard
                let customer = try PersistenceService.context.fetch(fetchRequest).first,
                let companiesSet = customer.companies
            else { return false }
            
            if let firstName = customer.firstName {
                print("Customer Name: \(firstName)")
            }
            
            return !companiesSet.allObjects.isEmpty
        } catch {
            fatalError("Failed to return a Boolean value for customer companies: \(error)")
        }
    }
    
    static func customerCompaniesCount() -> Int {
        // Returns the count of customer companies from the CoreData database
        let fetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
        do {
            guard
                let customer = try PersistenceService.context.fetch(fetchRequest).first,
                let companiesSet = customer.companies
            else { return 0 }
            
            return companiesSet.count
        } catch {
            fatalError("Failed to return a Boolean value for customer companies: \(error)")
        }
    }
    
    static func entityExists(entityName: String) -> Int {
        // Checks if a given entitiy has objects saved to CoreData
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.includesSubentities = false
        
        var entitiesCount = 0
        
        do {
            entitiesCount = try PersistenceService.context.count(for: fetchRequest)
        } catch {
            fatalError("Failed to fetch count for CoreData entity: \(error)")
        }
        
        return entitiesCount
    }
    
}
