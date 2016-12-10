// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation
import UIKit

// swiftlint:disable file_length
// swiftlint:disable line_length
// swiftlint:disable type_body_length

protocol StoryboardSceneType {
  static var storyboardName: String { get }
}

extension StoryboardSceneType {
  static func storyboard() -> UIStoryboard {
    return UIStoryboard(name: self.storyboardName, bundle: nil)
  }

  static func initialViewController() -> UIViewController {
    guard let vc = storyboard().instantiateInitialViewController() else {
      fatalError("Failed to instantiate initialViewController for \(self.storyboardName)")
    }
    return vc
  }
}

extension StoryboardSceneType where Self: RawRepresentable, Self.RawValue == String {
  func viewController() -> UIViewController {
    return Self.storyboard().instantiateViewController(withIdentifier: self.rawValue)
  }
  static func viewController(identifier: Self) -> UIViewController {
    return identifier.viewController()
  }
}

protocol StoryboardSegueType: RawRepresentable { }

extension UIViewController {
  func perform<S: StoryboardSegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
    performSegue(withIdentifier: segue.rawValue, sender: sender)
  }
}

struct StoryboardScene {
  enum CreationStoryboard: String, StoryboardSceneType {
    static let storyboardName = "CreationStoryboard"

    static func initialViewController() -> TeamCreationViewController {
      guard let vc = storyboard().instantiateInitialViewController() as? TeamCreationViewController else {
        fatalError("Failed to instantiate initialViewController for \(self.storyboardName)")
      }
      return vc
    }

    case projectCreationVCScene = "ProjectCreationVC"
    static func instantiateProjectCreationVC() -> ProjectCreationViewController {
      guard let vc = StoryboardScene.CreationStoryboard.projectCreationVCScene.viewController() as? ProjectCreationViewController
      else {
        fatalError("ViewController 'ProjectCreationVC' is not of the expected class ProjectCreationViewController.")
      }
      return vc
    }
  }
  enum LaunchScreen: StoryboardSceneType {
    static let storyboardName = "LaunchScreen"
  }
  enum Main: String, StoryboardSceneType {
    static let storyboardName = "Main"

    static func initialViewController() -> ViewController {
      guard let vc = storyboard().instantiateInitialViewController() as? ViewController else {
        fatalError("Failed to instantiate initialViewController for \(self.storyboardName)")
      }
      return vc
    }

    case colorGeneratorVCScene = "ColorGeneratorVC"
    static func instantiateColorGeneratorVC() -> ColorGenerationViewController {
      guard let vc = StoryboardScene.Main.colorGeneratorVCScene.viewController() as? ColorGenerationViewController
      else {
        fatalError("ViewController 'ColorGeneratorVC' is not of the expected class ColorGenerationViewController.")
      }
      return vc
    }

    case connectedUsersVCScene = "ConnectedUsersVC"
    static func instantiateConnectedUsersVC() -> ConnectedUsersTableViewController {
      guard let vc = StoryboardScene.Main.connectedUsersVCScene.viewController() as? ConnectedUsersTableViewController
      else {
        fatalError("ViewController 'ConnectedUsersVC' is not of the expected class ConnectedUsersTableViewController.")
      }
      return vc
    }

    case navTeamVCScene = "NavTeamVC"
    static func instantiateNavTeamVC() -> UINavigationController {
      guard let vc = StoryboardScene.Main.navTeamVCScene.viewController() as? UINavigationController
      else {
        fatalError("ViewController 'NavTeamVC' is not of the expected class UINavigationController.")
      }
      return vc
    }

    case teamVCScene = "TeamVC"
    static func instantiateTeamVC() -> TeamTableViewController {
      guard let vc = StoryboardScene.Main.teamVCScene.viewController() as? TeamTableViewController
      else {
        fatalError("ViewController 'TeamVC' is not of the expected class TeamTableViewController.")
      }
      return vc
    }

    case toolsVCScene = "ToolsVC"
    static func instantiateToolsVC() -> ToolsViewController {
      guard let vc = StoryboardScene.Main.toolsVCScene.viewController() as? ToolsViewController
      else {
        fatalError("ViewController 'ToolsVC' is not of the expected class ToolsViewController.")
      }
      return vc
    }
  }
  enum OnBoarding: StoryboardSceneType {
    static let storyboardName = "OnBoarding"

    static func initialViewController() -> UINavigationController {
      guard let vc = storyboard().instantiateInitialViewController() as? UINavigationController else {
        fatalError("Failed to instantiate initialViewController for \(self.storyboardName)")
      }
      return vc
    }
  }
}

struct StoryboardSegue {
  enum CreationStoryboard: String, StoryboardSegueType {
    case colorSegue = "ColorSegue"
  }
  enum Main: String, StoryboardSegueType {
    case connectedUserSegue = "ConnectedUserSegue"
    case createTeamSegue = "CreateTeamSegue"
    case projectCreationSegue = "ProjectCreationSegue"
    case teamCreationSegue = "TeamCreationSegue"
    case toolsSegue = "ToolsSegue"
    case loadColorChooser = "loadColorChooser"
    case teamCellSegue = "teamCellSegue"
    case teamContainerVC = "teamContainerVC"
  }
  enum OnBoarding: String, StoryboardSegueType {
    case createTeamSegue = "CreateTeamSegue"
    case showDraftSegue = "ShowDraftSegue"
    case skipSegue = "SkipSegue"
  }
}
