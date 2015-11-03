//
//  SDCAboutViewModel.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/15/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation
import ReactiveCocoa
import SafariServices

struct SDCAboutViewModel {
    let buildString         = MutableProperty<String>("")
    
    init() {
        let informations    = NSBundle.mainBundle().infoDictionary!
        let os              = informations["DTPlatformVersion"]!
        let build           = informations["CFBundleVersion"]!
        let version         = informations["CFBundleShortVersionString"]!
        
        buildString.value   = "Thank you for using Drivecast \(version) (\(build)) on iOS \(os)"
    }
}

extension SDCAboutViewModel {

    // Helper function to send emails
    private func sendEmailTo(address: String) {
        let URL = NSURL(string: "mailto:\(address)")!
        
        UIApplication.sharedApplication().openURL(URL)
    }
    
    // Helper function to open URLs
    private func openURL(urlString: String, viewController: UIViewController) {
        if let url = NSURL(string: urlString) {
            if #available(iOS 9.0, *) {
                let safari = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
                
                viewController.presentViewController(safari, animated: true, completion: nil)
            } else {
                 UIApplication.sharedApplication().openURL(url)
            }
        }
    }

    func showDetails(indexPath: NSIndexPath, viewController: UIViewController) {
        switch indexPath.section {
        case 0: // ABOUT
            switch indexPath.row {
            case 0: // WHAT IS SAFECAST
                openURL("http://blog.safecast.org", viewController: viewController)
            case 1: // ABOUT THE BGEIGIE NANO
                openURL("http://blog.safecast.org/bgeigie-nano", viewController: viewController)
            case 2: // READ OUR BLOG
                openURL("http://blog.safecast.org/news", viewController: viewController)
            case 3: // ACCESS THE MAP
                openURL("http://safecast.org/tilemap", viewController: viewController)
            case 4: // FAQ
                openURL("http://blog.safecast.org/faq", viewController: viewController)
            default:
                break
            }
        case 1: // WANT TO HELP
            switch indexPath.row {
            case 1: // DONATE
                openURL("http://blog.safecast.org/donate", viewController: viewController)
            case 2: // VOLUNTEER
                openURL("http://blog.safecast.org/volunteer", viewController: viewController)
            default:
                break
            }
        case 2: // ACKNOWLEDGMENTS
            switch indexPath.row {
            case 1: // MARC
                sendEmailTo("rollin.marc@gmail.com")
            case 2: // NICK
                sendEmailTo("ndolezal@gmail.com")
            case 4: // LICENCES
                openURL("http://blog.safecast.org/faq/licenses", viewController: viewController)
            case 5: // GITHUB
                openURL("https://github.com/mcrollin/Drivecast", viewController: viewController)
            case 7: // ALAMOFIRE
                openURL("https://github.com/Alamofire/Alamofire", viewController: viewController)
            case 8: // ANGLE GRADIENT LAYER
                openURL("https://github.com/paiv/AngleGradientLayer", viewController: viewController)
            case 9: // BEM SIMPLE LINE GRAPH
                openURL("https://github.com/Boris-Em/BEMSimpleLineGraph", viewController: viewController)
            case 10: // COCOAPODS
                openURL("https://cocoapods.org", viewController: viewController)
            case 11: // IQ KEYBOARDMANAGER
                openURL("https://github.com/hackiftekhar/IQKeyboardManager", viewController: viewController)
            case 12: // KVNProgress
                openURL("https://github.com/kevin-hirsch/KVNProgress", viewController: viewController)
            case 13: // REALM SWIFT
                openURL("https://realm.io", viewController: viewController)
            case 14: // SPINKIT
                openURL("https://github.com/raymondjavaxx/SpinKit-ObjC", viewController: viewController)
            case 15: // SNAPKIT
                openURL("https://github.com/SnapKit/SnapKit", viewController: viewController)
            case 16: // SWIFTY JSON
                openURL("https://github.com/SwiftyJSON/SwiftyJSON", viewController: viewController)
            case 17: // SWIFT GEN
                openURL("https://github.com/AliSoftware/SwiftGen", viewController: viewController)
            case 18: // REACTIVE COCOA
                openURL("https://github.com/ReactiveCocoa/ReactiveCocoa", viewController: viewController)
            case 20: // ICONS8
                openURL("https://icons8.com/", viewController: viewController)
            default:
                break
            }
        default:
            break
        }
    }
}