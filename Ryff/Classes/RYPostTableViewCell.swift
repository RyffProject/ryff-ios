//
//  RYPostTableViewCell.swift
//  Ryff
//
//  Created by Chris Laganiere on 9/4/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import UIKit

class RYPostTableViewCell: UITableViewCell {
    
    private let usernameLabel = UILabel(frame: CGRectZero)

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        NSLayoutConstraint.activateConstraints(subviewConstraints())
    }
    
    @availability(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Styling
    
    func styleWithPost(post: RYPost) {
        usernameLabel.text = post.user.username
    }
    
    // MARK: Layout
    
    private func subviewConstraints() -> [NSLayoutConstraint] {
        let viewsDict = ["usernameLabel": usernameLabel]
        
        var constraints: [AnyObject] = []
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-[usernameLabel]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDict)
        return constraints as? [NSLayoutConstraint] ?? []
    }

}
