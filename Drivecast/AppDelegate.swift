//
//  AppDelegate.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/15/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import KVNProgress
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        appearanceSetup()
        progressSetup()
        
        return true
    }
    
    // Setting up the general look and feel of the app
    private func appearanceSetup() {
        let mainColor           = UIColor(named: .Main)
        let fontSize:CGFloat    = UIFont.systemFontSize()
        
        if #available(iOS 8.2, *) {
            let font = UIFont.systemFontOfSize(fontSize, weight: UIFontWeightLight)
            
            UINavigationBar.appearance().titleTextAttributes  = [NSFontAttributeName: font]
        } else {
            let font = UIFont.systemFontOfSize(fontSize)
            
            UINavigationBar.appearance().titleTextAttributes  = [NSFontAttributeName: font]
        }
        
        let backImage   = UIImage(asset: .Back)
        
        UINavigationBar.appearance().backIndicatorImage = backImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backImage
        
        self.window?.tintColor                      = mainColor
        UIWindow.appearance().tintColor             = mainColor
        UIAlertView.appearance().tintColor          = mainColor
        UIActionSheet.appearance().tintColor        = mainColor
        UIButton.appearance().tintColor             = mainColor
        UITabBar.appearance().translucent           = false
        UINavigationBar.appearance().translucent    = false
        
        // Handles all keyboard events
        IQKeyboardManager.sharedManager().enable = true
    }
    
    // Configurating the progress activity screen
    private func progressSetup() {
        let configuration:KVNProgressConfiguration = KVNProgressConfiguration()
        let backgroundColor = UIColor(named: .Background)
        let mainColor       = UIColor(named: .Main)
        
        configuration.backgroundType = .Blurred
        configuration.backgroundFillColor = backgroundColor.colorWithAlphaComponent(0.7)
        configuration.backgroundTintColor = backgroundColor.colorWithAlphaComponent(0.8)
        configuration.circleStrokeForegroundColor   = mainColor
        configuration.statusColor                   = mainColor
        configuration.successColor                  = mainColor
        configuration.errorColor                    = mainColor
        configuration.fullScreen                    = true;
        
        KVNProgress.setConfiguration(configuration)
    }
}

