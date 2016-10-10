//
//  Session.swift
//  CoreDataTest
//
//  Created by Korhan Bircan on 10/10/16.
//  Copyright © 2016 Korhan Bircan. All rights reserved.
//

import Foundation
import TwitterKit

class Session {
    static let sharedInstance = Session()
    var userId: String?
    var client: TWTRAPIClient?
    var isUserLoggedIn: Bool {
        return !Twitter.sharedInstance().sessionStore.existingUserSessions().isEmpty && client != nil
    }
    var timelineEndpoint: String? {
        guard let userId = userId else {
            return nil
        }

        return "https://api.twitter.com/1.1/statuses/user_timeline.json?user_id=\(userId)&count=20"
    }

    private init() {
    }
}
