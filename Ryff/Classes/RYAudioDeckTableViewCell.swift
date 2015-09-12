//
//  RYAudioDeckTableViewCell.swift
//  Ryff
//
//  Created by Christopher Laganiere on 9/11/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import Foundation

class RYAudioDeckTableViewCell: UITableViewCell {
    
    static let preferredHeight: CGFloat = 50;
    
    private let playControl = RYPlayControl(frame: CGRectZero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        playControl.setTranslatesAutoresizingMaskIntoConstraints(false)
        addSubview(playControl)
        
        NSLayoutConstraint.activateConstraints(subviewConstraints())
    }
    
    @availability(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func styleWithReadyPost(post: RYPost) {
        playControl.setProgress(0.67, animated: false)
    }
    
    func styleWithDownload(post: RYPost) {
        playControl.setProgress(0.33, animated: false)
    }
    
    // Layout
    
    private func subviewConstraints() -> [NSLayoutConstraint] {
        let views = ["playControl": playControl]
        let metrics = ["relatedPadding": Constants.Global.RelatedElementPadding]
        var constraints: [AnyObject] = []
    
        // Horizontal
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-(relatedPadding)-[playControl]", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        
        // Play Control
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-(relatedPadding)-[playControl]-(relatedPadding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        constraints += [NSLayoutConstraint(item: playControl, attribute: .Width, relatedBy: .Equal, toItem: playControl, attribute: .Height, multiplier: 1.0, constant: 0.0)]
        
        return constraints as? [NSLayoutConstraint] ?? []
    }
    
}
