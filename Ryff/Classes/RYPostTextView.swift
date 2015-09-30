//
//  RYPostTextView.swift
//  Ryff
//
//  Created by Chris Laganiere on 9/6/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import UIKit

class RYPostTextView: UITextView {

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        backgroundColor = UIColor.clearColor()
        textColor = UIColor.lightGrayColor()
        editable = false
        self.textContainer.maximumNumberOfLines = 3
        self.textContainer.lineBreakMode = .ByTruncatingTail
        scrollEnabled = false
        setContentCompressionResistancePriority(UILayoutPriority.Low, forAxis: .Horizontal)
    }
    
    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
