// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation
import UIKit

protocol StoryboardSceneType {
  static var storyboardName: String { get }
}

extension StoryboardSceneType {
  static func storyboard() -> UIStoryboard {
    return UIStoryboard(name: self.storyboardName, bundle: nil)
  }

  static func initialViewController() -> UIViewController {
    return storyboard().instantiateInitialViewController()!
  }
}

extension StoryboardSceneType where Self: RawRepresentable, Self.RawValue == String {
  func viewController() -> UIViewController {
    return Self.storyboard().instantiateViewController(withIdentifier: self.rawValue)
  }
  static func viewController(_ identifier: Self) -> UIViewController {
    return identifier.viewController()
  }
}

protocol StoryboardSegueType: RawRepresentable { }

extension UIViewController {
  func performSegue<S: StoryboardSegueType>(_ segue: S, sender: AnyObject? = nil) where S.RawValue == String {
    self.performSegue(withIdentifier: segue.rawValue, sender: sender)
  }
}

struct StoryboardScene {
  enum CreationStoryboard: String, StoryboardSceneType {
    static let storyboardName = "CreationStoryboard"

    case ProjectCreationVCScene = "ProjectCreationVC"
    static func instantiateProjectCreationVC() -> ProjectCreationViewController {
      return StoryboardScene.CreationStoryboard.ProjectCreationVCScene.viewController() as! ProjectCreationViewController
    }
  }
  enum LaunchScreen: StoryboardSceneType {
    static let storyboardName = "LaunchScreen"
  }
  enum Main: String, StoryboardSceneType {
    static let storyboardName = "Main"

    case ColorGeneratorVCScene = "ColorGeneratorVC"
    static func instantiateColorGeneratorVC() -> ColorGenerationViewController {
      return StoryboardScene.Main.ColorGeneratorVCScene.viewController() as! ColorGenerationViewController
    }

    case ConnectedUsersVCScene = "ConnectedUsersVC"
    static func instantiateConnectedUsersVC() -> ConnectedUsersTableViewController {
      return StoryboardScene.Main.ConnectedUsersVCScene.viewController() as! ConnectedUsersTableViewController
    }

    case NavTeamVCScene = "NavTeamVC"
    static func instantiateNavTeamVC() -> UINavigationController {
      return StoryboardScene.Main.NavTeamVCScene.viewController() as! UINavigationController
    }

    case TeamVCScene = "TeamVC"
    static func instantiateTeamVC() -> TeamTableViewController {
      return StoryboardScene.Main.TeamVCScene.viewController() as! TeamTableViewController
    }

    case ToolsVCScene = "ToolsVC"
    static func instantiateToolsVC() -> ToolsViewController {
      return StoryboardScene.Main.ToolsVCScene.viewController() as! ToolsViewController
    }
  }
  enum OnBoarding: StoryboardSceneType {
    static let storyboardName = "OnBoarding"
  }
}

struct StoryboardSegue {
  enum CreationStoryboard: String, StoryboardSegueType {
    case ColorSegue = "ColorSegue"
  }
  enum Main: String, StoryboardSegueType {
    case ConnectedUserSegue = "ConnectedUserSegue"
    case CreateTeamSegue = "CreateTeamSegue"
    case ProjectCreationSegue = "ProjectCreationSegue"
    case TeamCreationSegue = "TeamCreationSegue"
    case LoadColorChooser = "loadColorChooser"
    case TeamCellSegue = "teamCellSegue"
    case TeamContainerVC = "teamContainerVC"
  }
  enum OnBoarding: String, StoryboardSegueType {
    case CreateTeamSegue = "CreateTeamSegue"
    case ShowDraftSegue = "ShowDraftSegue"
    case SkipSegue = "SkipSegue"
  }
}
