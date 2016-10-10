//
//  User+CoreDataProperties.swift
//  
//
//  Created by Korhan Bircan on 10/10/16.
//
//

import Foundation
import CoreData

extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User");
    }

    @NSManaged public var sortByDateAscending: Bool
    @NSManaged public var userId: String?
    @NSManaged public var tweets: NSSet?

}

// MARK: Generated accessors for tweets
extension User {

    @objc(addTweetsObject:)
    @NSManaged public func addToTweets(_ value: Tweet)

    @objc(removeTweetsObject:)
    @NSManaged public func removeFromTweets(_ value: Tweet)

    @objc(addTweets:)
    @NSManaged public func addToTweets(_ values: NSSet)

    @objc(removeTweets:)
    @NSManaged public func removeFromTweets(_ values: NSSet)

}
