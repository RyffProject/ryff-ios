//
//  Constants.swift
//  Ryff
//
//  Created by Chris Laganiere on 9/6/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import Foundation

struct Constants {
    
    struct Global {
        static let ContentMaximumWidth: CGFloat = 500
        static let ElementPadding: CGFloat = 15
        static let RelatedElementPadding: CGFloat = 8
    }
    
    struct Post {
        static let MinimumImageHeight: CGFloat = 150
        static let FooterHeight: CGFloat = 45
        static let AudioActionHeightSmall: CGFloat = 15
        static let AudioActionHeightLarge: CGFloat = 20
        static let AudioActionPadding: CGFloat = 10
    }
    
    struct User {
        static let AvatarHeight: CGFloat = 60
    }
    
    struct Mixer {
        static let PadSpacingRegular: CGFloat = 30
        static let PadSpacingCompact: CGFloat = 20
        static let ActionDimensionSmall: CGFloat = 15
        static let ActionDimensionLarge: CGFloat = 20
    }
    
    struct AudioDeck {
        static let ConsolePostImageDimensionCompact: CGFloat = 50
        static let ConsolePostImageDimensionRegular: CGFloat = 100
    }
    
}
