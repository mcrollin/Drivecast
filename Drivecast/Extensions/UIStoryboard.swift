// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation
import UIKit

protocol StoryboardScene : RawRepresentable {
  static var storyboardName : String { get }
  static func storyboard() -> UIStoryboard
  static func initialViewController() -> UIViewController
  func viewController() -> UIViewController
  static func viewController(identifier: Self) -> UIViewController
}

extension StoryboardScene where Self.RawValue == String {
  static func storyboard() -> UIStoryboard {
    return UIStoryboard(name: self.storyboardName, bundle: nil)
  }

  static func initialViewController() -> UIViewController {
    return storyboard().instantiateInitialViewController()!
  }

  func viewController() -> UIViewController {
    return Self.storyboard().instantiateViewControllerWithIdentifier(self.rawValue)
  }
  static func viewController(identifier: Self) -> UIViewController {
    return identifier.viewController()
  }
}

extension UIStoryboard {
  struct Scene {
    enum Main : String, StoryboardScene {
      static let storyboardName = "Main"

      case About = "About"
      static func aboutViewController() -> UINavigationController {
        return Main.About.viewController() as! UINavigationController
      }

      case Menu = "Menu"
      static func menuViewController() -> UITabBarController {
        return Main.Menu.viewController() as! UITabBarController
      }

      case Record = "Record"
      static func recordViewController() -> UINavigationController {
        return Main.Record.viewController() as! UINavigationController
      }
    }
  }

  struct Segue {
    enum Main : String {
      case OpenConsole = "OpenConsole"
    }
  }
}

