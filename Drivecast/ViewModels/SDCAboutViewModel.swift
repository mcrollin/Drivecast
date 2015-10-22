//
//  SDCAboutViewModel.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/15/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation
import ReactiveCocoa

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
    
    // Helper function to open schemes
    private func openScheme(URL: String) {
        let URL = NSURL(string: URL)!
        
        UIApplication.sharedApplication().openURL(URL)
    }
    

    func showDetails(indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0: // ABOUT
            switch indexPath.row {
            case 0: // WHAT IS SAFECAST
                openScheme("http://blog.safecast.org")
            case 1: // ABOUT THE BGEIGIE NANO
                openScheme("http://blog.safecast.org/bgeigie-nano")
            case 2: // READ OUR BLOG
                openScheme("http://blog.safecast.org/news")
            case 3: // ACCESS THE MAP
                openScheme("http://safecast.org/tilemap")
            case 4: // FAQ
                openScheme("http://blog.safecast.org/faq")
            default:
                break
            }
        case 1: // WANT TO HELP
            switch indexPath.row {
            case 1: // DONATE
                openScheme("http://blog.safecast.org/donate")
            case 2: // VOLUNTEER
                openScheme("http://blog.safecast.org/volunteer")
            default:
                break
            }
        case 2: // ACKNOWLEDGMENTS
            switch indexPath.row {
            case 1: // MARC
                openScheme("mailto:rollin.marc@gmail.com")
            case 2: // NICK
                openScheme("mailto:ndolezal@gmail.com")
            case 4: // LICENCES
                openScheme("http://blog.safecast.org/faq/licenses")
            case 5: // GITHUB
                openScheme("https://github.com/mcrollin/Drivecast")
            case 7: // ALAMOFIRE
                openScheme("https://github.com/Alamofire/Alamofire")
            case 8: // ANGLE GRADIENT LAYER
                openScheme("https://github.com/paiv/AngleGradientLayer")
            case 9: // BEM SIMPLE LINE GRAPH
                openScheme("https://github.com/Boris-Em/BEMSimpleLineGraph")
            case 10: // COCOAPODS
                openScheme("https://cocoapods.org")
            case 11: // IQ KEYBOARDMANAGER
                openScheme("https://github.com/hackiftekhar/IQKeyboardManager")
            case 12: // REALM SWIFT
                openScheme("https://realm.io")
            case 13: // SPINKIT
                openScheme("https://github.com/raymondjavaxx/SpinKit-ObjC")
            case 14: // SNAPKIT
                openScheme("https://github.com/SnapKit/SnapKit")
            case 15: // SWIFTY JSON
                openScheme("https://github.com/SwiftyJSON/SwiftyJSON")
            case 16: // SWIFT GEN
                openScheme("https://github.com/AliSoftware/SwiftGen")
            case 17: // REACTIVE COCOA
                openScheme("https://github.com/ReactiveCocoa/ReactiveCocoa")
            case 19: // ICONS8
                openScheme("https://icons8.com/#/web")
            default:
                break
            }
        default:
            break
        }
    }
}