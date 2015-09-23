//
//  RYUserProfileTableViewCell.swift
//  Ryff
//
//  Created by Chris Laganiere on 9/5/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import UIKit

class RYUserProfileTableViewCell: UITableViewCell {
    
    private let avatarImageView = UIImageView(frame: CGRectZero)
    private let usernameLabel = UILabel(frame: CGRectZero)
    private let userBioTextView = RYPostTextView(frame: CGRectZero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.clearColor()
        
        RYStyleSheet.styleProfileImageView(avatarImageView)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(avatarImageView)
        
        usernameLabel.textAlignment = .Center
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(usernameLabel)
        
        userBioTextView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(userBioTextView)
        
        NSLayoutConstraint.activateConstraints(subviewConstraints())
    }
    
    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Styling
    
    func styleWithUser(user: RYUser) {
        avatarImageView.sd_setImageWithURL(user.avatarURL)
        usernameLabel.text = user.username
        userBioTextView.text = user.bio
    }
    
    // MARK: Layout
    
    private func subviewConstraints() -> [NSLayoutConstraint] {
        let viewsDict = ["avatar": avatarImageView, "username": usernameLabel, "bio": userBioTextView]
        let metrics = ["padding": Constants.Global.ElementPadding, "avatarHeight": Constants.User.AvatarHeight, "maxWidth": Constants.Global.ContentMaximumWidth]
        
        var constraints: [NSLayoutConstraint] = []
        
        // Avatar
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=padding)-[avatar(avatarHeight)]-(>=padding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += [NSLayoutConstraint(item: avatarImageView, attribute: .CenterX, relatedBy: .Equal, toItem: avatarImageView.superview, attribute: .CenterX, multiplier: 1.0, constant: 0.0)]
        
        // Username Label
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=padding,==padding@900)-[username(<=maxWidth)]-(>=padding,==padding@900)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += [NSLayoutConstraint(item: usernameLabel, attribute: .CenterX, relatedBy: .Equal, toItem: usernameLabel.superview, attribute: .CenterX, multiplier: 1.0, constant: 0.0)]
        
        // User Bio TextView
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=padding,==padding@900)-[bio(<=maxWidth)]-(>=padding,==padding@900)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += [NSLayoutConstraint(item: userBioTextView, attribute: .CenterX, relatedBy: .Equal, toItem: userBioTextView.superview, attribute: .CenterX, multiplier: 1.0, constant: 0.0)]
        
        
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-(padding)-[avatar(avatarHeight)]-(padding)-[username]-(padding)-[bio]-(padding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        return constraints
    }

}
