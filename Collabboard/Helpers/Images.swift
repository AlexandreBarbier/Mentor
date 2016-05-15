// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import UIKit

extension UIImage {
  enum Asset: String {
    case AddViewIcon = "addViewIcon"
    case Ic_close = "ic_close"
    case Ic_images = "ic_images"
    case Ic_marker = "ic_marker"
    case Ic_pen = "ic_pen"
    case Ic_rubber = "ic_rubber"
    case Ic_team = "ic_team"
    case Ic_team_selected = "ic_team_selected"
    case Ic_text = "ic_text"
    case Ic_tools_marker = "ic_tools_marker"
    case Ic_tools_pen = "ic_tools_pen"
    case ProfileBlackIcon = "ProfileBlackIcon"
    case Settings = "settings"

    var image: UIImage {
      return UIImage(asset: self)
    }
  }

  convenience init!(asset: Asset) {
    self.init(named: asset.rawValue)
  }
}
