//
//  RYFadingVisualEffectView.swift
//  Ryff
//
//  Created by Chris Laganiere on 9/5/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import UIKit

/**
Direction of the fade effect.

- Top:    Fade from dark top to transparent bottom.
- Bottom: Fade from dark bottom to transparent top.
*/
enum RYFadingVisualEffectViewDirection: NSInteger {
    case Top = 0
    case Bottom = 1
}

/**
Creates a visual effect view whichs has its transparency fading with a gradient view dependent on the supplied direction.
*/

class RYFadingVisualEffectView: UIVisualEffectView {
    
    private static let FractionOfViewToFade: CGFloat = 0.5
    
    private let gradientView: CAGradientLayer
    
    /**
    Creates a `RYFadingVisualEffectView`
    
    :param: effect    Desired `UIVisualEffect`
    :param: direction `RYFadingVisualEffectViewDirection` for the fade to occur in.
    
    :returns: Instance of the fading visual effects view.
    */
    required init(effect: UIVisualEffect, direction: RYFadingVisualEffectViewDirection) {
        gradientView = RYFadingVisualEffectView.gradientTransparencyLayer(direction)
        super.init(effect: effect)
        self.layer.mask = gradientView
    }
    
    @availability(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientView.frame = bounds
    }
    
    // MARK: Private
    
    private class func gradientTransparencyLayer(direction: RYFadingVisualEffectViewDirection) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.whiteColor().CGColor, UIColor.clearColor().CGColor]
        switch (direction) {
        case .Top:
            gradientLayer.startPoint = CGPointMake(1.0, FractionOfViewToFade)
            gradientLayer.endPoint = CGPointMake(1.0, 1.0)
        case .Bottom:
            gradientLayer.startPoint = CGPointMake(1.0, 1.0-FractionOfViewToFade)
            gradientLayer.endPoint = CGPointMake(1.0, 0.0)
        }
        return gradientLayer
    }

}
