//
//  TimelineResponseMapper.swift
//  CoreDataTest
//
//  Created by Korhan Bircan on 10/9/16.
//  Copyright © 2016 Korhan Bircan. All rights reserved.
//

import Foundation

/*
 Anatomy of a tweet:
{
    contributors = "<null>";
    coordinates = "<null>";
    "created_at" = "Sun Oct 09 23:36:44 +0000 2016";
    entities =     {
        hashtags =         (
        );
        symbols =         (
        );
        urls =         (
        );
        "user_mentions" =         (
        );
    };
    "favorite_count" = 0;
    favorited = 0;
    geo = "<null>";
    id = 785262753556541441;
    "id_str" = 785262753556541441;
    "in_reply_to_screen_name" = "<null>";
    "in_reply_to_status_id" = "<null>";
    "in_reply_to_status_id_str" = "<null>";
    "in_reply_to_user_id" = "<null>";
    "in_reply_to_user_id_str" = "<null>";
    "is_quote_status" = 0;
    lang = und;
    place = "<null>";
    "retweet_count" = 0;
    retweeted = 0;
    source = "<a href=\"http://twitter.com\" rel=\"nofollow\">Twitter Web Client</a>";
    text = "oct 9 4:36";
    truncated = 0;
    user =     {
        "contributors_enabled" = 0;
        "created_at" = "Thu Jan 03 18:58:49 +0000 2013";
        "default_profile" = 1;
        "default_profile_image" = 1;
        description = "";
        entities =         {
            description =             {
                urls =                 (
                );
            };
        };
        "favourites_count" = 0;
        "follow_request_sent" = 0;
        "followers_count" = 0;
        following = 0;
        "friends_count" = 0;
        "geo_enabled" = 0;
        "has_extended_profile" = 0;
        id = 1058519142;
        "id_str" = 1058519142;
        "is_translation_enabled" = 0;
        "is_translator" = 0;
        lang = en;
        "listed_count" = 0;
        location = "";
        name = "test_95051";
        notifications = 0;
        "profile_background_color" = C0DEED;
        "profile_background_image_url" = "http://abs.twimg.com/images/themes/theme1/bg.png";
        "profile_background_image_url_https" = "https://abs.twimg.com/images/themes/theme1/bg.png";
        "profile_background_tile" = 0;
        "profile_image_url" = "http://abs.twimg.com/sticky/default_profile_images/default_profile_2_normal.png";
        "profile_image_url_https" = "https://abs.twimg.com/sticky/default_profile_images/default_profile_2_normal.png";
        "profile_link_color" = 0084B4;
        "profile_sidebar_border_color" = C0DEED;
        "profile_sidebar_fill_color" = DDEEF6;
        "profile_text_color" = 333333;
        "profile_use_background_image" = 1;
        protected = 0;
        "screen_name" = "test_950511";
        "statuses_count" = 6;
        "time_zone" = "<null>";
        url = "<null>";
        "utc_offset" = "<null>";
        verified = 0;
    };
}
*/

struct TimelineResponseMapper {
    static func parseResponse(_ jsonObject: Any?) {
        guard let jsonObject = jsonObject as? NSArray else {
            return
        }

        let context = CoreDataStack.sharedInstance.managedContext
        var tweets = [Tweet]()
        for jsonDictionary in jsonObject {
            guard let jsonDictionary = jsonDictionary as? NSDictionary else {
                continue
            }

            let tweet = Tweet(context: context)

            if let userDictionary = jsonDictionary["user"] as? NSDictionary {
                if let screenName = userDictionary["screen_name"] as? String {
                    tweet.screenName = screenName
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

            tweets.append(tweet)
        }

        CoreDataStack.sharedInstance.saveContext()
        tweets.removeAll()
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
