//
//  RYRiffCreateContainerViewController.swift
//  Ryff
//
//  Created by Christopher Laganiere on 10/4/14.
//  Copyright (c) 2014 Chris Laganiere. All rights reserved.
//

import UIKit

@objc
class RYRiffCreateContainerViewController: UIViewController {

    var riffEngine: RYRiffEngine
    var riffTracksViewController: RYRiffCreateTracksViewController!
    var riffDeckViewController: RYRiffCreateDeckViewController!
    
    // MARK: ViewController Life Cycle
    
    required init(coder aDecoder: NSCoder) {
        riffEngine = RYRiffEngine()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
