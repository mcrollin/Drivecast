// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import UIKit

extension UIColor {
    convenience init(rgbaValue: UInt32) {
        let red   = CGFloat((rgbaValue >> 24) & 0xff) / 255.0
        let green = CGFloat((rgbaValue >> 16) & 0xff) / 255.0
        let blue  = CGFloat((rgbaValue >>  8) & 0xff) / 255.0
        let alpha = CGFloat((rgbaValue      ) & 0xff) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension UIColor {
    enum Name : UInt32 {
        case Background = 0xf4f8f8ff
        case Main = 0x2ecc71ff
        case Alert = 0xe74c3cff
        case Text = 0x333333ff
        case LightText = 0xccccccff
    }

    convenience init(named name: Name) {
        self.init(rgbaValue: name.rawValue)
    }
}

