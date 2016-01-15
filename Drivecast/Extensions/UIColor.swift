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
  enum Name {
    /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#e74c3c"></span>
    /// Alpha: 100% <br/> (0xe74c3cff)
    case Alert
    /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#e98b39"></span>
    /// Alpha: 100% <br/> (0xe98b39ff)
    case Awaiting
    /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#f8fcff"></span>
    /// Alpha: 100% <br/> (0xf8fcffff)
    case Background
    /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#aaaaaa"></span>
    /// Alpha: 100% <br/> (0xaaaaaaff)
    case LightText
    /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#3498db"></span>
    /// Alpha: 100% <br/> (0x3498dbff)
    case Main
    /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#f39c12"></span>
    /// Alpha: 100% <br/> (0xf39c12ff)
    case Notice
    /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#dddddd"></span>
    /// Alpha: 100% <br/> (0xddddddff)
    case Separator
    /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#333333"></span>
    /// Alpha: 100% <br/> (0x333333ff)
    case Text

    var rgbaValue: UInt32! {
      switch self {
      case .Alert: return 0xe74c3cff
      case .Awaiting: return 0xe98b39ff
      case .Background: return 0xf8fcffff
      case .LightText: return 0xaaaaaaff
      case .Main: return 0x3498dbff
      case .Notice: return 0xf39c12ff
      case .Separator: return 0xddddddff
      case .Text: return 0x333333ff
      }
    }
  }

  convenience init(named name: Name) {
    self.init(rgbaValue: name.rgbaValue)
  }
}

