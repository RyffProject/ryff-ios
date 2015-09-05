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
    
    internal var riffSection = 0
    internal var dataSource: RYPostsDataSource?
    
    private let tableView = UITableView(frame: CGRectZero)
    
    required init(dataSource: RYPostsDataSource?) {
        super.init(nibName: nil, bundle: nil)
        if let dataSource = dataSource {
            configure(dataSource)
        }
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
        
        dataSource?.refreshContent()
    }
    
    func configure(dataSource: RYPostsDataSource) {
        self.dataSource = dataSource
        tableView.reloadData()
    }
    
    // MARK: RYPostsDataSourceDelegate
    
    func contentUpdated() {
        tableView.reloadData()
    }
    
    func contentFailedToUpdate() {
        
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
            return dataSource?.feedItems.count ?? 0
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == riffSection {
            return tableView.dequeueReusableCellWithIdentifier(RYPostTableViewCellReuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
        }
        else {
            assert(false, "Error: PostsViewController asked to supply tableview cell for undefined section")
            return UITableViewCell()
        }
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100;
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == riffSection {
            if let postCell = cell as? RYPostTableViewCell, post = dataSource?.feedItems[indexPath.row] as? RYPost {
                postCell.styleWithPost(post)
            }
        }
    }
    
}
