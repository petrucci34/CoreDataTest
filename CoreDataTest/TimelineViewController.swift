//
//  TimelineViewController.swift
//  CoreDataTest
//
//  Created by Korhan Bircan on 10/9/16.
//  Copyright © 2016 Korhan Bircan. All rights reserved.
//

import UIKit
import TwitterKit

class TimelineViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    fileprivate var clientError : NSError?
    fileprivate var isLoadingTimeline = false
    fileprivate var coreDataStack: CoreDataStack?
    fileprivate var dataSource = TimelineDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add a pull-to-refresh control.
        tableView.refreshControl = UIRefreshControl()
        if let refreshControl = tableView.refreshControl {
            refreshControl.addTarget(self, action: #selector(TimelineViewController.loadTimeline), for: .valueChanged)
        }

        // Hide empty row separators.
        tableView.tableFooterView = UIView(frame: .zero)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(sortByDate))

        dataSource.fetchedResultsController?.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: CoreDataStack.didRemoveAllNotificationName, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Initially hide the search bar.
        if let searchBarHeight = searchBar?.frame.size.height {
            tableView.contentOffset = CGPoint(x: 0, y: searchBarHeight)
        }

        tableView.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - private methods
private extension TimelineViewController {
    @objc func reloadData() {
        tableView.reloadData()
    }

    @objc func sortByDate() {
        // Flip whatever the sort ordering was previously.
        dataSource.sortByDateAscending = !dataSource.sortByDateAscending
        tableView.reloadData()
    }

    @objc func loadTimeline() {
        guard let client = Session.sharedInstance.client,
            let timelineEndpoint = Session.sharedInstance.timelineEndpoint else {
            tableView.refreshControl?.endRefreshing()
            tableView.reloadData()
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

            if connectionError != nil  || data == nil{
                print("Error: \(connectionError)")
                return
            }

            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
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
}

// MARK: - UITableViewDataSource
extension TimelineViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfRows(section: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: TweetCell.identifier, for: indexPath)
        if let tweet = dataSource.tweetAt(indexPath: indexPath) {
            TimelineViewCellAdapter.configure(cell as? TweetCell, tweet: tweet)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = dataSource.sectionInfo(section: section)
        return sectionInfo?.name
    }
}

// MARK: - NSFetchedResultsControllerDelegate
// This section is not used in the app but is left commented out for demonstration purposes.

extension TimelineViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
