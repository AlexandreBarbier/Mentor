//
//  ViewController.swift
//  Mentor
//
//  Created by Alexandre on 11/10/15.
//  Copyright © 2015 Alexandre Barbier. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import ABUIKit
import ABModel
import FirebaseDatabase
// MARK: - ViewController declaration
// TODO: fix resizing when rotate

private enum SegueIdentifier : String {
    case ShowTeamSegue
    case CreateTeamSegue
    case ConnectedUserSegue
}

class ViewController: UIViewController {
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var scrollView: DrawableScrollView!
    @IBOutlet var drawableView: DrawableView!
    @IBOutlet var bottomToolBar: UIToolbar!
    @IBOutlet var teamViewContainer: UIView!
    @IBOutlet var topToolbar: UIToolbar!
    @IBOutlet var bottomBarButtons: [UIBarButtonItem]!
    @IBOutlet var logoItem: UIBarButtonItem!
    @IBOutlet var showTeamButton: UIBarButtonItem!
    
    @IBOutlet var teamVCTopConstraint: NSLayoutConstraint!
    fileprivate var connectedUsersView : ConnectedUsersTableViewController?
    fileprivate var interfaceIsVisible = true
    fileprivate var canDownloadBG = true
    fileprivate var selectedTool = 0
    var imageBG : UIImageView?
    var teamViewContainerBackView:UIView!
}

// MARK: - View lifecycle
extension ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topToolbar.tintColor = UIColor.white
        logoItem.image = UIImage.Asset.Topbar_logo.image.withRenderingMode(.alwaysOriginal)
        selectTool(0)
        teamViewContainer.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.hideTeamController(_:)))
        teamViewContainerBackView = {
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            $0.addGestureRecognizer(tapGesture)
            return $0
        } (UIView(frame: teamViewContainer.bounds))
        teamViewContainer.addSubview(teamViewContainerBackView)
        scrollView.drawableView = drawableView
        progressView.progress = 0.0
        drawableView.loadingProgressBlock = {(progress, current, total) in
            OperationQueue.main.addOperation({ () -> Void in
                self.progressView.progress = Float(progress)
                self.progressView.isHidden = self.progressView.progress == 1.0
                if self.progressView.isHidden {
                    self.teamVCTopConstraint.constant = 0.0
                }
                else {
                   self.teamVCTopConstraint.constant = 6.0
                }
                
            })
        }
        activity.rounded()
        DebugConsoleView.debugView = DebugConsoleView(inView:view)
//        let _ = prefersStatusBarHidden
        loginUser()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
}

// MARK: - Gestures

extension ViewController {
    
    func hideTeamController(_ sender: AnyObject) {
        showTeam(self.showTeamButton)
    }
    
    @IBAction func hideInterface(_ sender: AnyObject) {
        if drawableView.getCurrentTool() == .text {
            let tap = sender as! UITapGestureRecognizer
            drawableView.addText(tap)
            return
        }
        let alpha = 1 - bottomToolBar.alpha
        if alpha == 1 {
            interfaceIsVisible = {
                bottomToolBar.isHidden = $0
                topToolbar.isHidden = $0
                progressView.isHidden = $0 ? $0 : self.progressView.progress == 1.0
                return $0
            }(interfaceIsVisible)
            
            
        }
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.bottomToolBar.alpha = alpha
            self.topToolbar.alpha = alpha
            self.progressView.alpha = alpha
            
        }, completion: { (finished) -> Void in
            if alpha != 1 {
                self.bottomToolBar.isHidden = self.interfaceIsVisible
                self.topToolbar.isHidden = self.interfaceIsVisible
                self.progressView.isHidden = self.interfaceIsVisible ? self.interfaceIsVisible : self.progressView.progress == 1.0
                
            }
        }) 
        interfaceIsVisible = !interfaceIsVisible
    }
}

// MARK: - Cloudkit management
extension ViewController {
    /**
     log the current user into iCloud
     */
    func loginUser() {
        guard let user = User.currentUser else {
            let alert = UIAlertController(title: "An error occured", message: "please restart DraftLink", preferredStyle: UIAlertControllerStyle.alert)
            self.present(alert, animated: true, completion: nil)
            return
        }
        if let connectedUser = self.connectedUsersView {
            connectedUser.teamCompletion =  { (project, team) in
                connectedUser.team = team
                OperationQueue.main.addOperation({ () -> Void in
                    self.initDrawing(team, project: project)
                    self.showTeam(self.showTeamButton)
                })
            }
            if let lastOpenedteamProject = Project.getLastOpen() {
                connectedUser.team = lastOpenedteamProject.team!
                OperationQueue.main.addOperation({ () -> Void in
                    self.initDrawing(lastOpenedteamProject.team!, project: lastOpenedteamProject.project!)
                    self.activity.stopAnimating()
                })
            }
            else {
                user.getTeams({ (teams, local, error) -> Void in
                    if !local {
                        if let team = teams.first {
                            connectedUser.team = team
                            team.getProjects({ (projects, local, error) -> Void in
                                if !local {
                                    if let project = projects.first {
                                        OperationQueue.main.addOperation({ () -> Void in
                                            self.initDrawing(team, project: project)
                                            project.setLastOpenForTeam(team)
                                            self.activity.stopAnimating()
                                        })
                                    }
                                }
                            })
                        }
                    }
                })
            }
        }}
    
    
    /**
     firebase initialisation for background change
     
     - parameter project: current project
     */
    func initFirebase(_ team: Team, project:Project) -> Void {
        cbFirebase.setupWithTeam(team, project: project)
        cbFirebase.firebaseBackgroundObserverHandle = cbFirebase.background!.observe(FIRDataEventType.childChanged, with: { (snap) -> Void in
            if self.canDownloadBG {
                self.drawableView.project!.refresh({ (updateObject:Project?) -> Void in
                    if let update = updateObject {
                        self.drawableView.project = update
                        self.setBG(self.drawableView.project!)
                    }
                })
            }
            self.canDownloadBG = true
        })
    }
}

// MARK: - Tools
extension ViewController : ToolsViewDelegate {
    
    fileprivate func configureDrawableView(_ tool:Tool) {
        drawableView.currentTool = tool
    }
    
    func selectTool(_ index: Int) {
        selectedTool = index
        bottomToolBar.items!.forEach { (item) in
            item.tintColor = item.tag == index ?  UIColor.draftLinkBlue() : UIColor.draftLinkGrey()
        }
    }
    
    func selectDrawingTool(_ tool:Tool) {
        configureDrawableView(tool)
    }
    
    
    func toolsViewDidSelectTools(_ toolsView:ToolsViewController, tool: Tool) {
        bottomBarButtons.forEach({ (item) in
            if item.tag == 0 {
                item.image = tool.getItemIcon()
            }
        })
        selectDrawingTool(tool)
    }
    
    func toolsViewChangeBrushSize(_ toolsView:ToolsViewController, size: CGFloat) {
        drawableView.lineWidth = size
    }
    
    func toolsViewChangeUserColor(_ toolsView:ToolsViewController, color: UIColor, colorSeed:CGFloat) {
        User.currentUser!.updateColorForTeam(connectedUsersView!.team!, color: color, colorSeed: colorSeed) { 
            self.drawableView.color = color
        }
    }
}

// MARK: - Drawing initialisation
extension ViewController {
    
    /**
     set the drawing color
     
     - parameter team: current team
     */
    func setDrawingColor(_ team:Team) {
        User.currentUser!.getTeamColors(team, completion: { (teamColor, userTeamColor:UserTeamColor, error) -> Void in
            self.drawableView.color = teamColor == nil ? UIColor.green : teamColor!
        })
    }
    /**
     set background for current project
     
     - parameter project: current project
     */
    func setBG(_ project:Project) {
        OperationQueue.main.addOperation({ () -> Void in
            if let bg = project.background {
                if self.imageBG == nil {
                    if let data = try? Data(contentsOf: URL(fileURLWithPath: bg.fileURL.path)) {
                        self.imageBG = {
                            $0.autoresizingMask = [.flexibleHeight,.flexibleHeight]
                            self.scrollView.insertSubview($0, at: 0)
                            $0.contentMode = .scaleAspectFill
                            $0.frame = self.drawableView.frame
                            return $0
                        }(UIImageView(image: UIImage(data: data)))
                    }
                }
                else {
                    if let imageData = try? Data(contentsOf: URL(fileURLWithPath: bg.fileURL.path)) {
                        self.imageBG!.image = UIImage(data: imageData)
                        self.imageBG!.frame = self.drawableView.frame
                    }
                    else {
                        self.imageBG!.image = nil
                        self.imageBG!.frame = self.drawableView.frame
                    }
                }
            }
            else {
                if self.imageBG != nil {
                    self.imageBG!.image = nil
                    self.imageBG!.frame = self.drawableView.frame
                }
            }
        })
    }
    /**
     drawing initialisation
     
     - parameter team:    current team
     - parameter project: current project
     */
    func initDrawing(_ team:Team, project:Project) {
        setDrawingColor(team)
        drawableView.project = project
        initFirebase(team, project: project)
        scrollView.contentSize = drawableView.frame.size
        setBG(project)
        activity.stopAnimating()
    }
}

// MARK: - background management
extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /**
     image picker controller delegate method
     
     - parameter picker: image picker
     - parameter info:   data from the image picker
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if imageBG == nil {
            imageBG = {
                $0.contentMode = .scaleAspectFill
                $0.frame = view.bounds
                $0.autoresizingMask = [.flexibleHeight,.flexibleHeight]
                scrollView.insertSubview($0, at: 0)
                return $0
            }(UIImageView(image: info[UIImagePickerControllerOriginalImage] as? UIImage))
            
        }
        else {
            imageBG?.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        drawableView.project!.saveBackground((imageBG?.image)!,completion: { () in
            OperationQueue.main.addOperation({ () -> Void in
                self.canDownloadBG = false
                cbFirebase.background!.updateChildValues(["bg":NSNumber(value: arc4random_uniform(UInt32(100)) as UInt32)])
            })
        })
        
        picker.dismiss(animated: true, completion: nil)
    }
    /**
     image picker controller delegate method
     
     - parameter picker: image picker
     */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imageBG?.image = nil
        if let project = drawableView.project {
            project.publicSave()
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Navigation
extension ViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = SegueIdentifier(rawValue: segue.identifier!) {
            switch identifier {
            case .ConnectedUserSegue :
                connectedUsersView = segue.destination as? ConnectedUsersTableViewController
                
                if let team = Project.getLastOpen() {
                    
                    self.connectedUsersView!.team = team.team
                    self.connectedUsersView!.teamCompletion =  { (project, team) in
                        OperationQueue.main.addOperation({ () -> Void in
                            self.initDrawing(team, project: project)
                        })
                    }
                    self.connectedUsersView!.reload()
                }
                self.activity.stopAnimating()
                break
            case .CreateTeamSegue :
                let teamCreationVC = segue.destination as! TeamCreationViewController
                teamCreationVC.showUser = true
                teamCreationVC.completion = { (team, project) in
                    OperationQueue.main.addOperation({ () -> Void in
                        self.initDrawing(team, project: project!)
                        teamCreationVC.dismiss(animated: true, completion: nil)
                        self.activity.stopAnimating()
                    })
                }
                break
            case .ShowTeamSegue :
                let navTeamVC = segue.destination as? UINavigationController
                let teamVC = navTeamVC!.viewControllers.first as? TeamTableViewController
                teamVC?.completion = { (project, team) in
                    
                    OperationQueue.main.addOperation({ () -> Void in
                        teamVC!.dismiss(animated: true, completion: nil)
                        self.initDrawing(team, project: project)
                    })
                }
                break
            }
        }
    }
}

// MARK: - Actions
extension ViewController {
    
    @IBAction func showBrushTools(_ sender:UIBarButtonItem) {
        if selectedTool != sender.tag {
            selectTool(sender.tag)
            selectDrawingTool(drawableView.brushTool)
        }
        else {
            selectTool(sender.tag)
            let popover : ToolsViewController = {
                $0.delegate = self
                $0.selectedTool = drawableView.getCurrentTool()
                $0.modalPresentationStyle = .formSheet
                $0.preferredContentSize = CGSize(width: 375, height: 500)
                $0.currentColor = drawableView.color
                return $0
            }(StoryboardScene.Main.instantiateToolsVC())
           
            self.present(popover, animated: true, completion: nil)
        }
    }
    
    /**
     eraser
     
     - parameter sender: the button that send the action
     */
    @IBAction func eraser(_ sender:UIBarButtonItem) {
        selectTool(sender.tag)
        configureDrawableView(.eraser)
    }
    
    /**
     set the text tool
     
     - parameter sender: the button that send the action
     */
    @IBAction func textTool(_ sender:UIBarButtonItem) {
        selectTool(sender.tag)
        configureDrawableView(.text)
    }
    
    /**
     import a background image
     
     - parameter sender: the button that send the action
     */
    @IBAction func importBG(_ sender:UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func showTeam(_ sender: AnyObject) {
        let button = sender as! UIBarButtonItem
        guard let connectedUsersView = connectedUsersView else {
            return
        }
        teamViewContainer.sendSubview(toBack: teamViewContainerBackView)
        if !teamViewContainer.isHidden {
            button.image = UIImage.Asset.Ic_team.image.withRenderingMode(.alwaysTemplate)
            connectedUsersView.segmentControl.selectedSegmentIndex = 0
            connectedUsersView.segmentControlChanged(connectedUsersView.segmentControl)
            teamViewContainer.isHidden = false
            connectedUsersView.reload()
            UIView.animate(withDuration: 0.5, animations: {
                connectedUsersView.view.layer.transform = CATransform3DMakeTranslation(0, -self.view.frame.size.height, 0)
                self.teamViewContainerBackView.backgroundColor = UIColor.draftLinkGrey().withAlphaComponent(0.0)
                }, completion: { (finished) in
                    if finished {
                        self.teamViewContainer.isHidden = true
                    }
            })
        }
        else {
            button.image = UIImage.Asset.Ic_team_selected.image.withRenderingMode(.alwaysTemplate)
            teamViewContainer.backgroundColor = UIColor.draftLinkGrey().withAlphaComponent(0.0)
            teamViewContainer.isHidden = false
            connectedUsersView.view.layer.transform = CATransform3DMakeTranslation(0, -self.view.frame.size.height, 0)
            UIView.animate(withDuration: 0.5, animations: {
                self.connectedUsersView!.view.layer.transform = CATransform3DIdentity
                self.teamViewContainerBackView.backgroundColor = UIColor.draftLinkGrey().withAlphaComponent(0.8)
            }) 
        }
    }
}
