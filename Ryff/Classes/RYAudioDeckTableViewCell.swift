//
//  RYAudioDeckTableViewCell.swift
//  Ryff
//
//  Created by Christopher Laganiere on 9/11/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import Foundation

class RYAudioDeckTableViewCell: UITableViewCell {
    
    static let preferredHeight: CGFloat = 50
    private let playControlDimension: CGFloat = 34
    
    private let playControl: RYPlayControl
    private let titleLabel = UILabel(frame: CGRectZero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        playControl = RYPlayControl(frame: CGRectMake(0, 0, playControlDimension, playControlDimension))
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        playControl.setTranslatesAutoresizingMaskIntoConstraints(false)
        addSubview(playControl)
        
        titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activateConstraints(subviewConstraints())
    }
    
    @availability(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func styleWithReadyPost(post: RYPost) {
        titleLabel.text = post.title
        playControl.setProgress(0.67, animated: false)
    }
    
    func styleWithDownload(post: RYPost) {
        titleLabel.text = post.title
        playControl.setProgress(0.33, animated: false)
    }
    
    // Layout
    
    private func subviewConstraints() -> [NSLayoutConstraint] {
        let views = ["playControl": playControl, "title": titleLabel]
        let metrics = ["relatedPadding": Constants.Global.RelatedElementPadding, "padding": Constants.Global.ElementPadding, "controlDimension": playControlDimension]
        var constraints: [AnyObject] = []
    
        // Horizontal
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-(relatedPadding)-[playControl(controlDimension)]-(relatedPadding)-[title]-(relatedPadding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)

        // Play Control
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[playControl(controlDimension)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        constraints += [NSLayoutConstraint(item: playControl, attribute: .CenterY, relatedBy: .Equal, toItem: playControl.superview, attribute: .CenterY, multiplier: 1.0, constant: 0.0)]
        
        // Title
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-[playControl(controlDimension)]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        
        return constraints as? [NSLayoutConstraint] ?? []
    }
    
}
