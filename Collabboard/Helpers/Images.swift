// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

#if os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  typealias Image = UIImage
#elseif os(OSX)
  import AppKit.NSImage
  typealias Image = NSImage
#endif

// swiftlint:disable file_length
// swiftlint:disable line_length

// swiftlint:disable type_body_length
enum Asset: String {
  case addViewIcon = "addViewIcon"
  case bgOnboarding = "bg_onboarding"
  case icClose = "ic_close"
  case icImages = "ic_images"
  case icMarker = "ic_marker"
  case icPen = "ic_pen"
  case icProjectMini = "ic_project_mini"
  case icProject = "ic_project"
  case icQuote = "ic_quote"
  case icRubber = "ic_rubber"
  case icTeamMini = "ic_team_mini"
  case icTeamSelected = "ic_team_selected"
  case icTeam = "ic_team"
  case icText = "ic_text"
  case icTong = "ic_tong"
  case icToolsMarker = "ic_tools_marker"
  case icToolsPen = "ic_tools_pen"
  case logoDraftlink = "logo_draftlink"
  case settings = "settings"
  case topbarLogo = "topbar_logo"

  var image: Image {
    return Image(asset: self)
  }
}
// swiftlint:enable type_body_length

extension Image {
  convenience init!(asset: Asset) {
    self.init(named: asset.rawValue)
  }
}
