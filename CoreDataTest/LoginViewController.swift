//
//  LoginViewController.swift
//  CoreDataTest
//
//  Created by Korhan Bircan on 10/9/16.
//  Copyright © 2016 Korhan Bircan. All rights reserved.
//

import UIKit
import TwitterKit

class LoginViewController: UIViewController {
    @IBOutlet weak var signInButton: TWTRLogInButton!
    @IBOutlet weak var signOutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create the Twitter login button.
        signInButton.logInCompletion =  { (session, error) in
            // As documented in https://dev.twitter.com/rest/reference/get/statuses/user_timeline.
            if let session = session {
                Session.sharedInstance.userId = session.userID
                Session.sharedInstance.client = TWTRAPIClient(userID: session.userID)
                self.updateButtonVisibility()
            } else {
                print("Login error: %@", error?.localizedDescription);
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateButtonVisibility()
    }

    @IBAction func didTapSignOutButton(_ sender: UIButton) {
        guard let userId = Session.sharedInstance.userId else {
            return
        }

        Twitter.sharedInstance().sessionStore.logOutUserID(userId)
        CoreDataStack.sharedInstance.removeAll(Tweet.self)
        updateButtonVisibility()
    }
}

private extension LoginViewController {
    func updateButtonVisibility() {
        signInButton.isHidden = Session.sharedInstance.isUserLoggedIn
        signOutButton.isHidden = !Session.sharedInstance.isUserLoggedIn
    }
}
