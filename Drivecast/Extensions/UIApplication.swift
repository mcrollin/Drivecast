//
//  UIApplication.swift
//  Drivecast
//
//  Created by Marc Rollin on 11/1/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit

extension UIApplication {
    static func showTab(index: Int) {
        let application = self.sharedApplication()
        let window      = application.keyWindow
        let navigation  = window?.rootViewController as? UINavigationController
        let tabBar      = navigation?.topViewController as? UITabBarController
        
        tabBar?.selectedIndex = index
    }
}
