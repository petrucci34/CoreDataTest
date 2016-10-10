//
//  TableViewController.swift
//  CoreDataTest
//
//  Created by Korhan Bircan on 10/9/16.
//  Copyright © 2016 Korhan Bircan. All rights reserved.
//

import UIKit
import TwitterKit

class TableViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    fileprivate var userId: String?
    fileprivate var client: TWTRAPIClient?
    fileprivate var timelineEndpoint: String?
    fileprivate var clientError : NSError?
    fileprivate var isLoadingTimeline = false
    fileprivate var coreDataStack: CoreDataStack?
    fileprivate var dataSource = TimelineDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add a pull-to-refresh control.
        tableView.refreshControl = UIRefreshControl()
        if let refreshControl = tableView.refreshControl {
            refreshControl.addTarget(self, action: #selector(TableViewController.loadTimeline), for: .valueChanged)
        }

        // Hide empty row separators.
        tableView.tableFooterView = UIView(frame: .zero)

//        dataSource.fetchedResultsController?.delegate = self

        updateClient()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Initially hide the search bar.
        if let searchBarHeight = searchBar?.frame.size.height {
            tableView.contentOffset = CGPoint(x: 0, y: searchBarHeight)
        }
    }
}

private extension TableViewController {
    // As documented in https://dev.twitter.com/rest/reference/get/statuses/user_timeline.
    func updateClient() {
        DispatchQueue.global(qos: .background).async {
            self.userId = Twitter.sharedInstance().sessionStore.session()?.userID
            if let userId = self.userId {
                self.client = TWTRAPIClient(userID: userId)
                self.timelineEndpoint = "https://api.twitter.com/1.1/statuses/user_timeline.json?user_id=\(userId)&count=20"

                self.loadTimeline()
            }
        }
    }

    @objc func loadTimeline() {
        guard let client = client, let timelineEndpoint = timelineEndpoint else {
            return
        }

        if isLoadingTimeline {
            return
        }

        let request = client.urlRequest(withMethod: "GET", url: timelineEndpoint, parameters: nil, error: &clientError)
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            self.isLoadingTimeline = false

            if let refreshControl = self.tableView.refreshControl {
                refreshControl.endRefreshing()
            }

            if connectionError != nil {
                print("Error: \(connectionError)")
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                TimelineResponseMapper.parseResponse(json)

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch let jsonError as NSError {
                print("json error: \(jsonError.localizedDescription)")
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension TableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfRows(section: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: TweetCell.identifier, for: indexPath)
        if let tweet = dataSource.tweetAt(indexPath: indexPath) {
            TableViewCellAdapter.configure(cell as? TweetCell, tweet: tweet)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = dataSource.sectionInfo(section: section)
        return sectionInfo?.name
    }
}

// MARK: - NSFetchedResultsControllerDelegate
/*
extension TableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            if let cell = tableView.cellForRow(at: indexPath!) as? TweetCell {
                if let indexPath = indexPath, let tweet = dataSource.tweetAt(indexPath: indexPath) {
                    TableViewCellAdapter.configure(cell, tweet: tweet)
                }
            }
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {

        let indexSet = IndexSet(integer: sectionIndex)

        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        default: break
        }
    }
}*/
