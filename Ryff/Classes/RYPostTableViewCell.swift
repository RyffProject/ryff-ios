//
//  RYPostTableViewCell.swift
//  Ryff
//
//  Created by Chris Laganiere on 9/4/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import UIKit
import SDWebImage

private struct PostCellConstants {
    private static let MaximumWidth: CGFloat = 400
    private static let MinimumImageHeight: CGFloat = 150
    private static let FooterHeight: CGFloat = 45
    private static let ElementPadding: CGFloat = 15
//    private static let StarWidth: CGFloat = 30
}

class RYPostTableViewCell: UITableViewCell {
    
    private let containerView = UIView(frame: CGRectZero)
    
    private let topDetailsView = UIView(frame: CGRectZero)
    private let topEffectsView = RYFadingVisualEffectView(effect: UIBlurEffect(style: .Dark), direction: .Top)
    private let usernameLabel = UILabel(frame: CGRectZero)
    private let postTitleLabel = UILabel(frame: CGRectZero)
    
    private let postImageView = UIImageView(frame: CGRectZero)
    
    private let bottomDetailsView = UIView(frame: CGRectZero)
    private let bottomEffectsView = RYFadingVisualEffectView(effect: UIBlurEffect(style: .Dark), direction: .Bottom)
    private let postDescriptionTextView = UITextView(frame: CGRectZero)
    private let starredImageView = UIImageView(frame: CGRectZero)
    private let starredCountLabel = UILabel(frame: CGRectZero)

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
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
        usernameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        topDetailsView.addSubview(usernameLabel)
        
        postTitleLabel.textColor = UIColor.whiteColor()
        postTitleLabel.textAlignment = .Right
        postTitleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        topDetailsView.addSubview(postTitleLabel)
        
        bottomDetailsView.backgroundColor = UIColor.clearColor()
        bottomDetailsView.setTranslatesAutoresizingMaskIntoConstraints(false)
        containerView.addSubview(bottomDetailsView)
        
        bottomEffectsView.setTranslatesAutoresizingMaskIntoConstraints(false)
        bottomDetailsView.addSubview(bottomEffectsView)
        
        postDescriptionTextView.backgroundColor = UIColor.clearColor()
        postDescriptionTextView.textColor = UIColor.lightGrayColor()
        postDescriptionTextView.textContainer.maximumNumberOfLines = 3
        postDescriptionTextView.textContainer.lineBreakMode = .ByTruncatingTail
        postDescriptionTextView.scrollEnabled = false
        postDescriptionTextView.setContentCompressionResistancePriority(UILayoutPriority.Low, forAxis: .Horizontal)
        postDescriptionTextView.setTranslatesAutoresizingMaskIntoConstraints(false)
        bottomDetailsView.addSubview(postDescriptionTextView)
        
        starredImageView.image = UIImage(named: "star")
        starredImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        bottomDetailsView.addSubview(starredImageView)
        
        starredCountLabel.textAlignment = .Right
        starredCountLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        bottomDetailsView.addSubview(starredCountLabel)
        
        NSLayoutConstraint.activateConstraints(subviewConstraints())
    }
    
    @availability(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Styling
    
    func styleWithPost(post: RYPost) {
        usernameLabel.text = post.user.username
        postTitleLabel.text = post.title
        postDescriptionTextView.text = post.content
        starredCountLabel.text = "\(post.upvotes)"
        
        if post.isUpvoted {
            starredImageView.tintColor = RYStyleSheet.audioActionColor()
            starredCountLabel.textColor = RYStyleSheet.audioActionColor()
        }
        else {
            starredImageView.tintColor = UIColor.lightGrayColor()
            starredCountLabel.textColor = UIColor.lightGrayColor()
        }
        
        if let _ = post.imageURL {
            postImageView.sd_setImageWithURL(post.imageURL, placeholderImage: nil)
        }
        else {
            postImageView.image = nil
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    // MARK: Layout
    
    class func heightForPost(post: RYPost) -> CGFloat {
//        if let _ = post.imageURL {
            return PostCellConstants.MaximumWidth + PostCellConstants.FooterHeight
//        }
//        else {
//            return PostCellConstants.MinimumImageHeight + PostCellConstants.FooterHeight
//        }
    }
    
    private func subviewConstraints() -> [NSLayoutConstraint] {
        let metrics = ["maxWidth": PostCellConstants.MaximumWidth, "padding": PostCellConstants.ElementPadding, "footerHeight": PostCellConstants.FooterHeight]
        let viewsDict = ["container": containerView, "topView": topDetailsView, "topEffects": topEffectsView, "username": usernameLabel, "title": postTitleLabel, "postImage": postImageView, "bottomView": bottomDetailsView, "bottomEffects": bottomEffectsView, "description": postDescriptionTextView, "starredImage": starredImageView, "starredCount": starredCountLabel]
        
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
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-(padding)-[description]-(padding)-[starredCount]-[starredImage]-(padding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-(padding)-[description]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-(>=0)-[starredImage]-(padding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += [NSLayoutConstraint(item: starredCountLabel, attribute: .CenterY, relatedBy: .Equal, toItem: starredImageView, attribute: .CenterY, multiplier: 1.0, constant: 0.0)]
//        constraints += [NSLayoutConstraint(item: starredImageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: PostCellConstants.StarWidth)]
        
        return constraints as? [NSLayoutConstraint] ?? []
    }

}
