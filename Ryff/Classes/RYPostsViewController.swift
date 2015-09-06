//
//  RYPostsViewController.swift
//  Ryff
//
//  Created by Chris Laganiere on 9/4/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import UIKit
import GTScrollNavigationBar

@objc class RYPostsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RYPostsDataSourceDelegate, RYPostTableViewCellDelegate {
    
    private let RYPostTableViewCellReuseIdentifier = "postCellReuseIdentifier"
    
    internal var riffSection = 0
    internal var dataSource: RYPostsDataSource?
    
    internal let tableView = UITableView(frame: CGRectZero, style: .Grouped)
    private let refreshControl: RYRefreshControl
    
    required init(dataSource: RYPostsDataSource?) {
        refreshControl = RYRefreshControl(inScrollView: tableView)
        super.init(nibName: nil, bundle: nil)
        if let dataSource = dataSource {
            configure(dataSource)
        }
        
        refreshControl.addTarget(self, action: Selector("refreshContent:"), forControlEvents: .ValueChanged)
    }
    
    @availability(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = RYStyleSheet.lightBackgroundColor()
        tableView.separatorStyle = .None
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(tableView)
        tableView.registerClass(RYPostTableViewCell.self, forCellReuseIdentifier: RYPostTableViewCellReuseIdentifier)
        
        NSLayoutConstraint.activateConstraints(subviewConstraints())
        dataSource?.refreshContent()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    func configure(dataSource: RYPostsDataSource) {
        self.dataSource = dataSource
        dataSource.delegate = self
        tableView.reloadData()
    }
    
    // MARK: RYPostTableViewCellDelegate
    
    func didTapUser(postCell: RYPostTableViewCell) {
        if let post = postForIndexPath(tableView.indexPathForCell(postCell)) {
            // Check if already looking at that user.
            if let userFeed = dataSource as? RYUserFeedDataSource {
                if (userFeed.user.userId == post.user.userId) {
                    return
                }
            }
            pushProfileViewController(post.user)
        }
    }
    
    func didTapPost(postCell: RYPostTableViewCell) {
        if let post = postForIndexPath(tableView.indexPathForCell(postCell)) {
            pushPostDetailsViewController(post)
        }
    }
    
    func didTapStarred(postCell: RYPostTableViewCell) {
        if let post = postForIndexPath(tableView.indexPathForCell(postCell)) {
            dataSource?.toggleStarred(post)
        }
    }
    
    private func postForIndexPath(indexPath: NSIndexPath?) -> RYPost? {
        if let postIndex = indexPath?.row, post = dataSource?.postAtIndex(postIndex) {
            return post
        }
        return nil
    }
    
    // MARK: RYPostsDataSourceDelegate
    
    func contentUpdated() {
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    func contentFailedToUpdate() {
        refreshControl.endRefreshing()
    }
    
    func postUpdatedAtIndex(postIndex: Int) {
        let indexPath = NSIndexPath(forItem: postIndex, inSection: riffSection)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
    
    // MARK: Layout
    
    private func subviewConstraints() -> [NSLayoutConstraint] {
        let viewsDict = ["tableView": tableView]
        
        var constraints: [AnyObject] = []
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[tableView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDict)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[tableView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDict)
        return constraints as? [NSLayoutConstraint] ?? []
    }
    
    // MARK: Actions
    
    func refreshContent(refreshControl: RYRefreshControl) {
        dataSource?.refreshContent()
    }
    
    func loadMoreContent(loadMoreControl: RYLoadMoreControl) {
        dataSource?.loadMoreContent()
    }
    
    // MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == riffSection {
            return dataSource?.numberOfPosts() ?? 0
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == riffSection {
            let cell = tableView.dequeueReusableCellWithIdentifier(RYPostTableViewCellReuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
            cell.selectionStyle = .None
            return cell
        }
        else {
            assert(false, "Error: PostsViewController asked to supply tableview cell for undefined section")
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == riffSection {
            if let post = dataSource?.postAtIndex(indexPath.row) {
                return RYPostTableViewCell.heightForPost(post)
            }
        }
        return 0.0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == riffSection {
            if let postCell = cell as? RYPostTableViewCell, post = dataSource?.postAtIndex(indexPath.row) {
                postCell.styleWithPost(post, delegate: self)
            }
        }
    }
    
}
