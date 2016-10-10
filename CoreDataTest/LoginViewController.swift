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
    var twitterButton: TWTRLogInButton!
    var signedInUserButton: UIButton!
    var isUserLoggedIn: Bool {
        return !Twitter.sharedInstance().sessionStore.existingUserSessions().isEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create the Twitter login button.
        twitterButton = TWTRLogInButton { (session, error) in
            if let _ = session {
                self.presentTableViewController()
            } else {
                print("Login error: %@", error!.localizedDescription);
            }
        }
        twitterButton.center = view.center
        view.addSubview(twitterButton)
        twitterButton.isHidden = isUserLoggedIn

        // Create the "Show my tweets" button.
        signedInUserButton = UIButton(frame: twitterButton.frame)
        signedInUserButton.setTitle("Show my tweets", for: .normal)
        signedInUserButton.setTitleColor(UIColor.black, for: .normal)
        signedInUserButton.addTarget(self, action: #selector(presentTableViewController), for: .touchUpInside)
        view.addSubview(signedInUserButton)
        signedInUserButton.isHidden = !isUserLoggedIn
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        twitterButton.isHidden = isUserLoggedIn
        signedInUserButton.isHidden = !isUserLoggedIn
    }
}

internal extension LoginViewController {
    func presentTableViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tableViewController = storyboard.instantiateViewController(withIdentifier: "TableViewController")
        navigationController?.pushViewController(tableViewController, animated: true)
    }
}
