//
//  TimelineDataSource.swift
//  CoreDataTest
//
//  Created by Korhan Bircan on 10/9/16.
//  Copyright © 2016 Korhan Bircan. All rights reserved.
//

import Foundation
import CoreData

class TimelineDataSource {
    let fetchedResultsController: NSFetchedResultsController<Tweet>?
    var fetchRequest: NSFetchRequest<Tweet> = Tweet.fetchRequest()
    fileprivate let sortKey = "sortByDateAscending"
    var sortByDateAscending: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: sortKey)
            sortByDate()
        }
        get {
            if let sortAscending = UserDefaults.standard.value(forKey: sortKey) as? Bool {
                return sortAscending
            }
            return false
        }
    }

    init() {
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Tweet.createdAt), ascending: false)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: CoreDataStack.sharedInstance.managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)

        sortByDate()

        NotificationCenter.default.addObserver(self, selector: #selector(sortByDate), name: CoreDataStack.didRemoveAllNotificationName, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func filter(keyword: String) {
        do {
            fetchRequest.predicate = keyword.isEmpty ? nil : NSPredicate(format: "text contains[c] %@", keyword)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Tweet.createdAt), ascending: sortByDateAscending)]
            try fetchedResultsController?.performFetch()

        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }

    @objc func sortByDate() {
        do {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Tweet.createdAt), ascending: sortByDateAscending)]
            try fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }

    func numberOfSections() -> Int {
        guard let sections = fetchedResultsController?.sections else {
            return 0
        }

        return sections.count
    }

    func sectionInfo(section: Int) -> NSFetchedResultsSectionInfo? {
        guard let sections = fetchedResultsController?.sections else {
            return nil
        }

        if section >= sections.count {
            return nil
        }

        return fetchedResultsController?.sections?[section]
    }

    func numberOfRows(section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController?.sections?[section] else {
            return 0
        }

        return sectionInfo.numberOfObjects
    }

    func tweetAt(indexPath: IndexPath) -> Tweet? {
        return fetchedResultsController?.object(at: indexPath)
    }
}
