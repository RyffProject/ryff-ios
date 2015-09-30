//
//  RYStarredView.swift
//  Ryff
//
//  Created by Chris Laganiere on 9/6/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import UIKit

class RYStarredView: UIView {
    
    private let starredImageView = UIImageView(frame: CGRectZero)
    private let starredCountLabel = UILabel(frame: CGRectZero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clearColor()
        
        starredImageView.image = UIImage(named: "star")
        starredImageView.contentMode = .ScaleAspectFit
        starredImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(starredImageView)
        
        starredCountLabel.alpha = 0.5
        starredCountLabel.textAlignment = .Right
        starredCountLabel.setDynamicStyle(TextStyle.Body, fontStyle: .Regular)
        starredCountLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(starredCountLabel)
        
        NSLayoutConstraint.activateConstraints(subviewConstraints())
    }
    
    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Styling
    
    func style(starred: Bool, text: String) {
        style(starred)
        starredCountLabel.text = text
    }
    
    func style(starred: Bool) {
        if starred {
            starredImageView.tintColor = RYStyleSheet.audioActionColor()
            starredCountLabel.textColor = RYStyleSheet.audioActionColor()
        }
        else {
            starredImageView.tintColor = UIColor.lightGrayColor()
            starredCountLabel.textColor = UIColor.lightGrayColor()
        }
    }
    
    // MARK: Private
    
    func subviewConstraints() -> [NSLayoutConstraint] {
        let viewsDict = ["image": starredImageView, "count": starredCountLabel]
        let metrics = ["relatedPadding": Constants.Global.RelatedElementPadding, "actionHeight": Constants.Post.AudioActionHeightLarge]
        
        var constraints: [NSLayoutConstraint] = []
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[count]-(relatedPadding)-[image(actionHeight)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[image(actionHeight)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += [NSLayoutConstraint(item: starredCountLabel, attribute: .CenterY, relatedBy: .Equal, toItem: starredImageView, attribute: .CenterY, multiplier: 1.0, constant: 0.0)]
        return constraints
    }

}
