//
//  KRLCollectionViewGridLayout+Ryff.swift
//  Ryff
//
//  Created by Chris Laganiere on 9/6/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import Foundation
import KRLCollectionViewGridLayout

extension KRLCollectionViewGridLayout {
    
    func style(traitEnvironment: UITraitEnvironment) {
        var spacing: CGFloat
        if (traitEnvironment.traitCollection.horizontalSizeClass == .Compact) {
            numberOfItemsPerLine = 2
            spacing = Constants.Mixer.CompactPadSpacing
        }
        else {
            numberOfItemsPerLine = 4
            spacing = Constants.Mixer.RegularPadSpacing
        }
        sectionInset = UIEdgeInsetsMake(spacing, spacing, spacing, spacing)
        interitemSpacing = spacing
        lineSpacing = spacing
        aspectRatio = 1.0
    }
    
}
