//
//  UIKit+BNRDynamicTypeManager.swift
//  Ryff
//
//  Created by Christopher Laganiere on 9/7/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import Foundation

public struct TextStyle {
    static let Headline = UIFontTextStyleHeadline
    static let Body = UIFontTextStyleBody
    static let Subheadline = UIFontTextStyleSubheadline
    static let Footnote = UIFontTextStyleFootnote
    static let caption1 = UIFontTextStyleCaption1
    static let caption2 = UIFontTextStyleCaption2
}

extension UILabel {
    
    func setDynamicStyle(textStyle: String, fontStyle: FontStyle) {
        BNRDynamicTypeManager.sharedInstance().watchLabel(self, textStyle: textStyle, fontStyle: fontStyle)
    }
    
}

extension UITextView {
    
    func setDynamicStyle(textStyle: String, fontStyle: FontStyle) {
        BNRDynamicTypeManager.sharedInstance().watchTextView(self, textStyle: textStyle, fontStyle: fontStyle)
    }
    
}

extension UITextField {
    
    func setDynamicStyle(textStyle: String, fontStyle: FontStyle) {
        BNRDynamicTypeManager.sharedInstance().watchTextField(self, textStyle: textStyle, fontStyle: fontStyle)
    }
    
}

extension UIButton {
    
    func setDynamicStyle(textStyle: String, fontStyle: FontStyle) {
        BNRDynamicTypeManager.sharedInstance().watchButton(self, textStyle: textStyle, fontStyle: fontStyle)
    }
    
}
