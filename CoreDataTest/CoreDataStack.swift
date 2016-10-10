//
//  CoreDataStack.swift
//  CoreDataTest
//
//  Created by Korhan Bircan on 10/9/16.
//  Copyright © 2016 Korhan Bircan. All rights reserved.
//


import Foundation
import CoreData

// The reason this is a class and not a struct is the error when we try to invoke 'CoreDataStack.sharedInstance.saveContext()':
// Cannot use mutating member on immutable value: 'sharedInstance' is a 'let' constant.
class CoreDataStack {
    fileprivate let modelName = "Model"
    static let sharedInstance = CoreDataStack()
    static let didRemoveAllNotificationName = NSNotification.Name(rawValue: "didRemoveAllNotification")

    lazy var managedContext: NSManagedObjectContext = {
        let context = self.storeContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()

    lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            } else {
                print("Persistent store location: \(storeDescription.url?.absoluteString)")
            }
        }
        return container
    }()

    func saveContext () {
        guard managedContext.hasChanges else {
            return
        }

        do {
            try self.managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }

    func removeAll<T: NSManagedObject>(_ type: T.Type) {
        let fetchRequest = T.self.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try managedContext.execute(batchDeleteRequest)
            saveContext()
            NotificationCenter.default.post(name: CoreDataStack.didRemoveAllNotificationName, object: self)
        } catch {
            print("Batch deletion failed.")
        }
    }
}
