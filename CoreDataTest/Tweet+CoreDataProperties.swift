//
//  Tweet+CoreDataProperties.swift
//  
//
//  Created by Korhan Bircan on 10/10/16.
//
//

import Foundation
import CoreData

extension Tweet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tweet> {
        return NSFetchRequest<Tweet>(entityName: "Tweet");
    }

    @NSManaged public var createdAt: NSDate?
    @NSManaged public var favoriteCount: Int64
    @NSManaged public var text: String?
    @NSManaged public var tweetId: Int64
    @NSManaged public var screenName: String?
    @NSManaged public var user: User?

}
