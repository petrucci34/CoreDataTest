//
//  FirstViewController.swift
//  CoreDataTest
//
//  Created by Korhan Bircan on 10/9/16.
//  Copyright © 2016 Korhan Bircan. All rights reserved.
//

import UIKit
import TwitterKit

class FirstViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let logInButton = TWTRLogInButton { (session, error) in
            if let _ = session {
                self.presentTableViewController()
            } else {
                NSLog("Login error: %@", error!.localizedDescription);
            }
        }

        logInButton.center = view.center
        view.addSubview(logInButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

private extension FirstViewController {
    func presentTableViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tableViewController = storyboard.instantiateViewController(withIdentifier: "TableViewController")
        navigationController?.pushViewController(tableViewController, animated: true)
    }
}
