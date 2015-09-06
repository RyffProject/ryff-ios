//
//  RYRiffCreateCollectionViewController.swift
//  Ryff
//
//  Created by Christopher Laganiere on 8/15/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import UIKit
import KRLCollectionViewGridLayout

@objc
class RYRiffCreateCollectionViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, AudioEngineDelegate, RYRiffCreateNodeCellDelegate {
    
    private let NumberOfNodes = 8
    private let NodeCellReuseIdentifier = "RiffNodeCell"
    
    private var riffEngine: RYRiffAudioEngine
    
    private let collectionViewLayout = KRLCollectionViewGridLayout()
    private let collectionView: UICollectionView
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        riffEngine = RYRiffAudioEngine(riffNodeCount: NumberOfNodes)
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewLayout)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        riffEngine.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    @availability(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = UIColor.greenColor()
        collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activateConstraints(subviewConstraints())
        
        collectionView.registerClass(RYRiffCreateNodeCollectionViewCell.self, forCellWithReuseIdentifier: NodeCellReuseIdentifier)
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        collectionViewLayout.style(self)
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    // MARK: RYRiffCreateNodeCellDelegate
    
    func clearHitOnNodeCell(nodeCell: RYRiffCreateNodeCollectionViewCell) {
        if let indexPath = collectionView.indexPathForCell(nodeCell) {
            riffEngine.clearNodeAtIndex(indexPath.row)
        }
    }
    
    // MARK: AudioEngineDelegate
    
    func nodeStatusChangedAtIndex(index: Int) {
        if let riffNode = riffEngine.nodeAtIndex(index) {
            let indexPath = NSIndexPath(forItem: index, inSection: 0)
            if let nodeCell = collectionView.cellForItemAtIndexPath(indexPath) as? RYRiffCreateNodeCollectionViewCell {
                nodeCell.styleWithRiffNode(riffNode)
            }
        }
    }
    
    // MARK: Styling
    
    func subviewConstraints() -> [NSLayoutConstraint] {
        let viewsDict = ["collectionView": collectionView]
        
        var constraints: [AnyObject] = []
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[collectionView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDict)
        constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDict)
        return constraints as? [NSLayoutConstraint] ?? []
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier(NodeCellReuseIdentifier, forIndexPath: indexPath) as! RYRiffCreateNodeCollectionViewCell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NumberOfNodes
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let nodeCell = cell as? RYRiffCreateNodeCollectionViewCell, riffNode = riffEngine.nodeAtIndex(indexPath.row) {
            nodeCell.styleWithRiffNode(riffNode)
            nodeCell.delegate = self
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        riffEngine.toggleNodeAtIndex(indexPath.row)
    }
}
