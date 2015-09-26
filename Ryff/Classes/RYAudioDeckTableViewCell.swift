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
    
    private var post: RYPost?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        playControl = RYPlayControl(frame: CGRectMake(0, 0, playControlDimension, playControlDimension))
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        playControl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(playControl)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        NSLayoutConstraint.activateConstraints(subviewConstraints())
    }
    
    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func styleWithReadyPost(post: RYPost) {
        self.post = post
        titleLabel.text = post.title
        
        if let currentlyPlaying = RYAudioDeck.sharedAudioDeck.currentlyPlaying where currentlyPlaying == post {
            // Style for currentlyPlaying.
            playControl.hideProgress(false)
            playControl.hideCenterImage(true)
            
            playControl.setProgress(RYAudioDeck.sharedAudioDeck.playbackProgress, animated: false)
        }
        else {
            // Style for ready in playlist.
            playControl.hideProgress(true)
            playControl.hideCenterImage(false)
        }
    }
    
    func styleWithDownload(post: RYPost) {
        self.post = post
        titleLabel.text = post.title
        playControl.setProgress(0.33, animated: false)
    }
    
    // Layout
    
    private func subviewConstraints() -> [NSLayoutConstraint] {
        let views = ["playControl": playControl, "title": titleLabel]
        let metrics = ["relatedPadding": Constants.Global.RelatedElementPadding, "padding": Constants.Global.ElementPadding, "controlDimension": playControlDimension]
        var constraints: [NSLayoutConstraint] = []
    
        // Horizontal
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-(relatedPadding)-[playControl(controlDimension)]-(relatedPadding)-[title]-(relatedPadding)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)

        // Play Control
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:[playControl(controlDimension)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        constraints += [NSLayoutConstraint(item: playControl, attribute: .CenterY, relatedBy: .Equal, toItem: playControl.superview, attribute: .CenterY, multiplier: 1.0, constant: 0.0)]
        
        // Title
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-[title]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views)
        
        return constraints
    }
    
}
