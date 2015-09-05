//
//  RYProfileViewController.swift
//  Ryff
//
//  Created by Chris Laganiere on 9/4/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import UIKit

class RYProfileViewController: RYPostsViewController {
    
    private let RYProfileTableViewCellReuseIdentifier = "profileCellReuseIdentifier"
    private let SectionProfile = 0
    private let SectionRiff = 1
    
    convenience init(user: RYUser?) {
        if let user = user {
            self.init(dataSource: RYUserFeedDataSource(user: user))
        }
        else {
            self.init(dataSource: nil)
        }
        riffSection = 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func configure(dataSource: RYPostsDataSource) {
        if let userDataSource = dataSource as? RYUserFeedDataSource {
            styleForUser(userDataSource.user)
        }
        super.configure(dataSource)
    }
    
    func styleForUser(user: RYUser) {
        self.title = user.username
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SectionRiff {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == SectionRiff {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
        return tableView.dequeueReusableCellWithIdentifier(RYProfileTableViewCellReuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == SectionRiff {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
        return 100
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == SectionRiff {
            super.tableView(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
        }
        else if indexPath.section == SectionProfile {
            if let profileCell = cell as? RYProfileTableViewCell, userDataSource = dataSource as? RYUserFeedDataSource {
                profileCell.styleWithUser(userDataSource.user)
            }
        }
    }

}
