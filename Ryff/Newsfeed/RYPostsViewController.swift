//
//  RYPostsViewController.swift
//  Ryff
//
//  Created by Chris Laganiere on 9/4/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import UIKit

@objc class RYPostsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RYPostsDataSourceDelegate {
    
    private let RYPostTableViewCellReuseIdentifier = "postCellReuseIdentifier"
    
    private let tableView = UITableView(frame: CGRectZero)
    
    private let dataSource: RYPostsDataSource
    
    required init(dataSource: RYPostsDataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    @availability(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(tableView)
        NSLayoutConstraint.activateConstraints(subviewConstraints())
        tableView.registerClass(RYPostTableViewCell.self, forCellReuseIdentifier: RYPostTableViewCellReuseIdentifier)
        
        dataSource.refreshContent()
    }
    
    // MARK: RYPostsDataSourceDelegate
    
    func contentUpdated() {
        tableView.reloadData()
    }
    
    func contentFailedToUpdate() {
        
    }
    
    func postUpdatedAtIndex(postIndex: Int) {
        let indexPath = NSIndexPath(forItem: postIndex, inSection: 0)
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
        dataSource.refreshContent()
    }
    
    func loadMoreContent(loadMoreControl: RYLoadMoreControl) {
        dataSource.loadMoreContent()
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.feedItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier(RYPostTableViewCellReuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100;
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let postCell = cell as? RYPostTableViewCell, post = dataSource.feedItems[indexPath.row] as? RYPost {
            postCell.styleWithPost(post)
        }
    }
    
}
