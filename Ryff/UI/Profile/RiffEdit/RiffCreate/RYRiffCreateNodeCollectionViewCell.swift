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
    
    @IBOutlet weak var clearButton: UIButton!
    
    weak var delegate: RYRiffCreateNodeCellDelegate?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
    
    @IBAction func clearButtonHit(sender: AnyObject) {
        delegate?.clearHitOnNodeCell(self)
    }
    
}
