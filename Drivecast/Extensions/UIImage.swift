// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation
import UIKit

extension UIImage {
  enum Asset : String {
    case Dot = "Dot"
    case Header = "Header"
    case Back = "Back"
    case Center = "Center"
    case Console = "Console"
    case Github = "Github"
    case Home = "Home"
    case More = "More"
    case Record = "Record"
    case Resize = "Resize"
    case Upload = "Upload"
    case SafecastBoxed = "SafecastBoxed"
    case SafecastLettersBig = "SafecastLettersBig"
    case SafecastLettersSmall = "SafecastLettersSmall"
    case Separator = "Separator"

    var image: UIImage {
      return UIImage(asset: self)
    }
  }

  convenience init!(asset: Asset) {
    self.init(named: asset.rawValue)
  }
}

