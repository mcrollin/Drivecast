// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation
import UIKit

extension UIImage {
    enum Asset : String {
        case Dot = "Dot"
        case Back = "Back"
        case Console = "Console"
        case Home = "Home"
        case Minus = "Minus"
        case More = "More"
        case Plus = "Plus"
        case Record = "Record"
        case Resize = "Resize"
        case Upload = "Upload"
        case SafecastLettersBig = "SafecastLettersBig"
        case SafecastLettersSmall = "SafecastLettersSmall"
        case Separator = "Separator"

        var image: UIImage {
            return UIImage(asset: self)
        }
    }

    convenience init(asset: Asset) {
        self.init(named: asset.rawValue)!
    }
}

