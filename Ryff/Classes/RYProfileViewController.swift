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
    
     required init(dataSource: RYPostsDataSource?) {
        super.init(dataSource: dataSource)
        riffSection = SectionRiff
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(RYUserProfileTableViewCell.self, forCellReuseIdentifier: RYProfileTableViewCellReuseIdentifier)
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
        let cell = tableView.dequeueReusableCellWithIdentifier(RYProfileTableViewCellReuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
        cell.selectionStyle = .None
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == SectionRiff {
            return super.tableView(tableView, estimatedHeightForRowAtIndexPath: indexPath)
        }
        return 150
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == SectionRiff {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == SectionRiff {
            super.tableView(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
        }
        else if indexPath.section == SectionProfile {
            if let profileCell = cell as? RYUserProfileTableViewCell, userDataSource = dataSource as? RYUserFeedDataSource {
                profileCell.styleWithUser(userDataSource.user)
            }
        }
    }

}
