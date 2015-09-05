//
//  UIViewController+Transitions.swift
//  Ryff
//
//  Created by Chris Laganiere on 9/5/15.
//  Copyright (c) 2015 Chris Laganiere. All rights reserved.
//

import Foundation

/**
Adds functionality to UIViewController for pushing common Ryff view controller.
*/

extension UIViewController {
    
    func pushProfileViewControllerForUser(user: RYUser) {
        let dataSource = RYUserFeedDataSource.postsDataSourceWithUser(user)
        let profileViewController = RYProfileViewController(dataSource: dataSource)
        navigationController?.pushViewController(profileViewController, animated: true)
    }
    
}
