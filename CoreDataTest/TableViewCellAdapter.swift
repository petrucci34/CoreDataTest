//
//  TimelineViewCellAdapter.swift
//  CoreDataTest
//
//  Created by Korhan Bircan on 10/9/16.
//  Copyright © 2016 Korhan Bircan. All rights reserved.
//

import UIKit

struct TimelineViewCellAdapter {
    static func configure(_ tweetCell: TweetCell?, tweet: Tweet?) {
        guard let tweetCell = tweetCell, let tweet = tweet else {
            return
        }

        tweetCell.user.text = tweet.screenName
        tweetCell.date.text = TimelineResponseMapper.dateToString(tweet.createdAt)
        tweetCell.content.text = tweet.text
        tweetCell.favoriteCount.text = "\(tweet.favoriteCount)"
    }
}
