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
    var fetchedResultsController: NSFetchedResultsController<Tweet>?

    init() {
        let fetchRequest: NSFetchRequest<Tweet> = Tweet.fetchRequest()
        let timeSort = NSSortDescriptor(key: #keyPath(Tweet.createdAt), ascending: false)
        let favoriteSort = NSSortDescriptor(key: #keyPath(Tweet.favoriteCount), ascending: false)

        fetchRequest.sortDescriptors = [timeSort, favoriteSort]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: CoreDataStack.sharedInstance.managedContext,
            sectionNameKeyPath: nil,
            cacheName: "timeline")

        do {
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
