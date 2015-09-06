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
        starredImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        addSubview(starredImageView)
        
        starredCountLabel.alpha = 0.5
        starredCountLabel.textAlignment = .Right
        starredCountLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        addSubview(starredCountLabel)
        
        NSLayoutConstraint.activateConstraints(subviewConstraints())
    }
    
    @availability(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Styling
    
    func style(starred: Bool, starredCount: Int) {
        style(starred)
        starredCountLabel.text = "\(starredCount)"
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
        let metrics = ["relatedPadding": Constants.Global.RelatedElementPadding]
        
        var constraints: [AnyObject] = []
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[count]-(relatedPadding)-[image]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: viewsDict)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[image]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDict)
        constraints += [NSLayoutConstraint(item: starredCountLabel, attribute: .CenterY, relatedBy: .Equal, toItem: starredImageView, attribute: .CenterY, multiplier: 1.0, constant: 0.0)]
        return constraints as? [NSLayoutConstraint] ?? []
    }

}
