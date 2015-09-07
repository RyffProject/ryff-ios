//
//  RYPostTableViewCell.swift
//  Ryff
//
//  Created by Chris Laganiere on 9/4/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import UIKit
import SDWebImage

protocol RYPostTableViewCellDelegate: class {
    func didTapUser(postCell: RYPostTableViewCell)
    func didTapPost(postCell: RYPostTableViewCell)
    func didTapStarred(postCell: RYPostTableViewCell)
}

class RYPostTableViewCell: UITableViewCell {
    
    /// Delegate to notify when actions are attempted.
    private weak var delegate: RYPostTableViewCellDelegate?
    
    /// Specifies whether the post for which this cell was last styled was starred.
    private var postStarred: Bool = false
    
    private let containerView = UIView(frame: CGRectZero)
    
    private let topDetailsView = UIView(frame: CGRectZero)
    private let topEffectsView = RYFadingVisualEffectView(effect: UIBlurEffect(style: .Dark), direction: .Top)
    private let usernameLabel = UILabel(frame: CGRectZero)
    private let postTitleLabel = UILabel(frame: CGRectZero)
    
    private let postImageView = UIImageView(frame: CGRectZero)
    
    private let bottomDetailsView = UIView(frame: CGRectZero)
    private let bottomEffectsView = RYFadingVisualEffectView(effect: UIBlurEffect(style: .Dark), direction: .Bottom)
    private let postDescriptionTextView = RYPostTextView(frame: CGRectZero)
    private let starredView = RYStarredView(frame: CGRectZero)

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Styling
        
        backgroundColor = UIColor.clearColor()
        
        containerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        containerView.backgroundColor = UIColor.clearColor()
        addSubview(containerView)
        
        postImageView.backgroundColor = RYStyleSheet.tabBarColor()
        postImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        containerView.addSubview(postImageView)
        
        topDetailsView.backgroundColor = UIColor.clearColor()
        topDetailsView.setTranslatesAutoresizingMaskIntoConstraints(false)
        containerView.addSubview(topDetailsView)
        
        topEffectsView.setTranslatesAutoresizingMaskIntoConstraints(false)
        topDetailsView.addSubview(topEffectsView)
        
        usernameLabel.textColor = UIColor.lightTextColor()
        usernameLabel.setDynamicStyle(TextStyle.Subheadline, fontStyle: .Bold)
        usernameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        topDetailsView.addSubview(usernameLabel)
        
        postTitleLabel.textColor = UIColor.whiteColor()
        postTitleLabel.textAlignment = .Right
        postTitleLabel.setDynamicStyle(TextStyle.Subheadline, fontStyle: .Bold)
        postTitleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        topDetailsView.addSubview(postTitleLabel)
        
        bottomDetailsView.backgroundColor = UIColor.clearColor()
        bottomDetailsView.setTranslatesAutoresizingMaskIntoConstraints(false)
        containerView.addSubview(bottomDetailsView)
        
        bottomEffectsView.setTranslatesAutoresizingMaskIntoConstraints(false)
        bottomDetailsView.addSubview(bottomEffectsView)
        
        postDescriptionTextView.setDynamicStyle(TextStyle.Body, fontStyle: .Regular)
        postDescriptionTextView.setTranslatesAutoresizingMaskIntoConstraints(false)
        bottomDetailsView.addSubview(postDescriptionTextView)
        
        starredView.setTranslatesAutoresizingMaskIntoConstraints(false)
        bottomDetailsView.addSubview(starredView)
        
        NSLayoutConstraint.activateConstraints(subviewConstraints())
        
        // Actions
        
        usernameLabel.userInteractionEnabled = true
        let userTapGesture = UITapGestureRecognizer(target: self, action: Selector("didTapUser:"))
        usernameLabel.addGestureRecognizer(userTapGesture)
        
        postTitleLabel.userInteractionEnabled = true
        let postTitleTapGesture = UITapGestureRecognizer(target: self, action: Selector("didTapPost:"))
        postTitleLabel.addGestureRecognizer(postTitleTapGesture)
        
        postImageView.userInteractionEnabled = true
        let postTapGesture = UITapGestureRecognizer(target: self, action: Selector("didTapPost:"))
        postImageView.addGestureRecognizer(postTapGesture)
        
        starredView.userInteractionEnabled = true
        let starredTapGesture = UITapGestureRecognizer(target: self, action: Selector("didTapStarred:"))
        starredView.addGestureRecognizer(starredTapGesture)
    }
    
    @availability(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Styling
    
    class func heightForPost(post: RYPost) -> CGFloat {
        //        if let _ = post.imageURL {
        return Constants.Global.ContentMaximumWidth + Constants.Post.FooterHeight
        //        }
        //        else {
        //            return PostCellConstants.MinimumImageHeight + PostCellConstants.FooterHeight
        //        }
    }
    
    func styleWithPost(post: RYPost, delegate: RYPostTableViewCellDelegate) {
        self.delegate = delegate
        
        usernameLabel.text = post.user.username
        postTitleLabel.text = post.title
        postDescriptionTextView.text = post.content
        postStarred = post.isStarred
        starredView.style(postStarred, text: "\(post.upvotes)")
        
        if let _ = post.imageURL {
            postImageView.sd_setImageWithURL(post.imageURL, placeholderImage: nil)
        }
        else {
            postImageView.image = nil
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    // MARK: Actions
    
    func didTapUser(tapGesture: UITapGestureRecognizer) {
        delegate?.didTapUser(self)
    }
    
    func didTapPost(tapGesture: UITapGestureRecognizer) {
        delegate?.didTapPost(self)
    }
    
    func didTapStarred(tapGesture: UITapGestureRecognizer) {
        starredView.style(!postStarred)
        delegate?.didTapStarred(self)
    }
    
    // MARK: Layout
    
    private func subviewConstraints() -> [NSLayoutConstraint] {
        let metrics = ["maxWidth": Constants.Global.ContentMaximumWidth, "padding": Constants.Global.ElementPadding, "footerHeight": Constants.Post.FooterHeight]
        let viewsDict = ["container": containerView, "topView": topDetailsView, "topEffects": topEffectsView, "username": usernameLabel, "title": postTitleLabel, "postImage": postImageView, "bottomView": bottomDetailsView, "bottomEffects": bottomEffectsView, "description": postDescriptionTextView, "starred": starredView]
        
        var constraints: [AnyObject] = []
        
        // Container
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-(>=0,==0@900)-[container(<=maxWidth,==maxWidth@900)]-(>=0,==0@900)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += [NSLayoutConstraint(item: containerView, attribute: .CenterX, relatedBy: .Equal, toItem: containerView.superview, attribute: .CenterX, multiplier: 1.0, constant: 0.0)]
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[container]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        
        // Top Details View
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[topView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[topView]", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        
        // Top Effects View
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[topEffects]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[topEffects]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        
        // Top Details Subviews
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-(padding)-[username]-(padding)-[title]-(padding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-(padding)-[username]-(padding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-(padding)-[title]", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        
        // Image
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[postImage]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDict)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[postImage]-(footerHeight)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += [NSLayoutConstraint(item: postImageView, attribute: .Height, relatedBy: .Equal, toItem: postImageView, attribute: .Width, multiplier: 1.0, constant: 0.0)]
        
        // Bottom Details
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[bottomView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[bottomView]-(footerHeight)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        
        // Bottom Effects View
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[bottomEffects]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[bottomEffects]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        
        // Bottom Details Subviews
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-(padding)-[description]-(padding)-[starred]-(padding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-(padding)-[description]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-(>=0)-[starred]-(padding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        
        return constraints as? [NSLayoutConstraint] ?? []
    }

}
