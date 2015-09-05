//
//  RYRiffCreateCollectionViewController.swift
//  Ryff
//
//  Created by Christopher Laganiere on 8/15/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import UIKit

@objc
class RYRiffCreateCollectionViewController : UICollectionViewController, AudioEngineDelegate, RYRiffCreateNodeCellDelegate {
    
    private let NumberOfNodes = 12
    private let NodeCellReuseIdentifier = "RiffNodeCell"
    
    private var riffEngine: RYRiffAudioEngine

    required init(coder aDecoder: NSCoder) {
        riffEngine = RYRiffAudioEngine(riffNodeCount: NumberOfNodes)
        super.init(coder: aDecoder)
        riffEngine.delegate = self
    }
    
    // MARK: RYRiffCreateNodeCellDelegate
    
    func clearHitOnNodeCell(nodeCell: RYRiffCreateNodeCollectionViewCell) {
        if let indexPath = self.collectionView?.indexPathForCell(nodeCell) {
            riffEngine.clearNodeAtIndex(indexPath.row)
        }
    }
    
    // MARK: AudioEngineDelegate
    
    func nodeStatusChangedAtIndex(index: Int) {
        if let riffNode = self.riffEngine.nodeAtIndex(index) {
            let indexPath = NSIndexPath(forItem: index, inSection: 0)
            if let nodeCell = self.collectionView?.cellForItemAtIndexPath(indexPath) as? RYRiffCreateNodeCollectionViewCell {
                nodeCell.styleWithRiffNode(riffNode)
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier(NodeCellReuseIdentifier, forIndexPath: indexPath) as! RYRiffCreateNodeCollectionViewCell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NumberOfNodes
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let nodeCell = cell as? RYRiffCreateNodeCollectionViewCell, riffNode = riffEngine.nodeAtIndex(indexPath.row) {
            nodeCell.styleWithRiffNode(riffNode)
            nodeCell.delegate = self
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        riffEngine.toggleNodeAtIndex(indexPath.row)
    }
}
