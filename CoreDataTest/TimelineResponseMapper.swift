//
//  TimelineResponseMapper.swift
//  CoreDataTest
//
//  Created by Korhan Bircan on 10/9/16.
//  Copyright © 2016 Korhan Bircan. All rights reserved.
//

import Foundation

struct TimelineResponseMapper {
    static func parseResponse(_ jsonObject: Any?) {
        guard let jsonObject = jsonObject as? NSArray else {
            return
        }

        let context = CoreDataStack.sharedInstance.managedContext

        for jsonDictionary in jsonObject {
            guard let jsonDictionary = jsonDictionary as? NSDictionary else {
                continue
            }

            let tweet = Tweet(context: context)

            if let userDictionary = jsonDictionary["user"] as? NSDictionary {
                if let screentName = userDictionary["screen_name"] as? String {
                    tweet.user = screentName
                }
            }

            if let favoriteCount = jsonDictionary["favorite_count"] as? NSNumber {
                tweet.favoriteCount = favoriteCount.int64Value
            }

            if let tweetId = jsonDictionary["id"] as? NSNumber {
                tweet.tweetId = tweetId.int64Value

            }

            if let text = jsonDictionary["text"] as? String {
                tweet.text = text
            }

            if let createdAt = jsonDictionary["created_at"] as? String {
                tweet.createdAt = TimelineResponseMapper.stringToDate(createdAt)
            }

            CoreDataStack.sharedInstance.saveContext()
        }
    }
}

extension TimelineResponseMapper {
    static func dateToString(_ date: NSDate?) -> String? {
        guard let date = date else {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd, HH:mm:ss"

        return dateFormatter.string(from: date as Date)
    }

    static func stringToDate(_ string: String?) -> NSDate? {
        guard let string = string else {
            return nil
        }

        // Expecting string of the format "Sun Oct 09 23:36:44 +0000 2016"
        // Documentation: http://unicode.org/reports/tr35/tr35-6.html#Date_Format_Patterns
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss ZZZ y"
        let date = dateFormatter.date(from: string)

        return date as NSDate?
    }
}
