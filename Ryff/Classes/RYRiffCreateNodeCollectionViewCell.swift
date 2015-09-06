//
//  RYRiffCreateNodeCollectionViewCell.swift
//  Ryff
//
//  Created by Christopher Laganiere on 8/15/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import UIKit

protocol RYRiffCreateNodeCellDelegate: class {
    func clearHitOnNodeCell(nodeCell: RYRiffCreateNodeCollectionViewCell)
}

class RYRiffCreateNodeCollectionViewCell: UICollectionViewCell {
    
    private let clearImageView = UIImageView(frame: CGRectZero)
    
    weak var delegate: RYRiffCreateNodeCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @availability(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func styleWithRiffNode(riffNode: RYRiffAudioNode) {
        if (riffNode.isRecording) {
            self.backgroundColor = UIColor.redColor()
        }
        else if (riffNode.isActive) {
            self.backgroundColor = UIColor.whiteColor()
        }
        else if (riffNode.isReadyToPlay) {
            self.backgroundColor = UIColor.grayColor()
        }
        else {
            self.backgroundColor = UIColor.blueColor()
        }
    }
    
    // MARK: Actions
    
    func didTapClear(tapGesture: UITapGestureRecognizer) {
        delegate?.clearHitOnNodeCell(self)
    }
    
}
