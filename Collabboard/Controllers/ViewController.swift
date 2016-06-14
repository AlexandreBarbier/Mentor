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
    
    private var connectedUsersView : ConnectedUsersTableViewController?
    private var interfaceIsVisible = true
    private var canDownloadBG = true
    private var selectedTool = 0
    var imageBG : UIImageView?
    var teamViewContainerBackView:UIView!
}

// MARK: - View lifecycle
extension ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topToolbar.tintColor = UIColor.draftLinkGrey()
        logoItem.image = UIImage.Asset.Topbar_logo.image.imageWithRenderingMode(.AlwaysOriginal)
        selectTool(0)
        teamViewContainer.hidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.hideTeamController(_:)))
        teamViewContainerBackView = {
            $0.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            $0.addGestureRecognizer(tapGesture)
            return $0
        } (UIView(frame: teamViewContainer.bounds))
        teamViewContainer.addSubview(teamViewContainerBackView)
        scrollView.drawableView = drawableView
        progressView.progress = 0.0
        drawableView.loadingProgressBlock = {(progress, current, total) in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.progressView.progress = Float(progress)
                self.progressView.hidden = self.progressView.progress == 1.0
            })
        }
        activity.rounded()
        DebugConsoleView.debugView = DebugConsoleView(inView:view)
        prefersStatusBarHidden()
        loginUser()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}

// MARK: - Gestures

extension ViewController {
    
    func hideTeamController(sender: AnyObject) {
        showTeam(self.showTeamButton)
    }
    
    @IBAction func hideInterface(sender: AnyObject) {
        if drawableView.getCurrentTool() == .text {
            let tap = sender as! UITapGestureRecognizer
            drawableView.addText(tap)
            return
        }
        let alpha = 1 - bottomToolBar.alpha
        if alpha == 1 {
            interfaceIsVisible = {
                bottomToolBar.hidden = $0
                topToolbar.hidden = $0
                progressView.hidden = $0 ? $0 : self.progressView.progress == 1.0
                return $0
            }(interfaceIsVisible)
            
            
        }
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.bottomToolBar.alpha = alpha
            self.topToolbar.alpha = alpha
            self.progressView.alpha = alpha
            
        }) { (finished) -> Void in
            if alpha != 1 {
                self.bottomToolBar.hidden = self.interfaceIsVisible
                self.topToolbar.hidden = self.interfaceIsVisible
                self.progressView.hidden = self.interfaceIsVisible ? self.interfaceIsVisible : self.progressView.progress == 1.0
                
            }
        }
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
            let alert = UIAlertController(title: "An error occured", message: "please restart Mentor", preferredStyle: UIAlertControllerStyle.Alert)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        if let connectedUser = self.connectedUsersView {
            connectedUser.teamCompletion =  { (project, team) in
                connectedUser.team = team
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.initDrawing(team, project: project)
                    self.showTeam(self.showTeamButton)
                })
            }
            if let lastOpenedteamProject = Project.getLastOpen() {
                connectedUser.team = lastOpenedteamProject.team!
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
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
                                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
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
    func initFirebase(team: Team, project:Project) -> Void {
        cbFirebase.setupWithTeam(team, project: project)
        cbFirebase.firebaseBackgroundObserverHandle = cbFirebase.background!.observeEventType(FIRDataEventType.ChildChanged, withBlock: { (snap) -> Void in
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
    
    private func configureDrawableView(tool:Tool) {
        drawableView.currentTool = tool
    }
    
    func selectTool(index: Int) {
        selectedTool = index
        bottomToolBar.items!.forEach { (item) in
            item.tintColor = item.tag == index ?  UIColor.draftLinkBlue() : UIColor.draftLinkGrey()
        }
    }
    
    func selectDrawingTool(tool:Tool) {
        configureDrawableView(tool)
    }
    
    
    func toolsViewDidSelectTools(toolsView:ToolsViewController, tool: Tool) {
        bottomBarButtons.forEach({ (item) in
            if item.tag == 0 {
                item.image = tool.getItemIcon()
            }
        })
        selectDrawingTool(tool)
    }
    
    func toolsViewChangeBrushSize(toolsView:ToolsViewController, size: CGFloat) {
        drawableView.lineWidth = size
    }
    
    func toolsViewChangeUserColor(toolsView:ToolsViewController, color: UIColor, colorSeed:CGFloat) {
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
    func setDrawingColor(team:Team) {
        User.currentUser!.getTeamColors(team, completion: { (teamColor, userTeamColor:UserTeamColor, error) -> Void in
            self.drawableView.color = teamColor == nil ? UIColor.greenColor() : teamColor
        })
    }
    /**
     set background for current project
     
     - parameter project: current project
     */
    func setBG(project:Project) {
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            if let bg = project.background {
                if self.imageBG == nil {
                    if let data = NSData(contentsOfFile: bg.fileURL.path!) {
                        self.imageBG = {
                            $0.autoresizingMask = [.FlexibleHeight,.FlexibleHeight]
                            self.scrollView.insertSubview($0, atIndex: 0)
                            $0.contentMode = .ScaleAspectFill
                            $0.frame = self.drawableView.frame
                            return $0
                        }(UIImageView(image: UIImage(data: data)))
                    }
                }
                else {
                    if let imageData = NSData(contentsOfFile: bg.fileURL.path!) {
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
    func initDrawing(team:Team, project:Project) {
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
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if imageBG == nil {
            imageBG = {
                $0.contentMode = .ScaleAspectFill
                $0.frame = view.bounds
                $0.autoresizingMask = [.FlexibleHeight,.FlexibleHeight]
                scrollView.insertSubview($0, atIndex: 0)
                return $0
            }(UIImageView(image: info[UIImagePickerControllerOriginalImage] as? UIImage))
            
        }
        else {
            imageBG?.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        drawableView.project!.saveBackground((imageBG?.image)!,completion: { () in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.canDownloadBG = false
                cbFirebase.background!.updateChildValues(["bg":NSNumber(unsignedInt:arc4random_uniform(UInt32(100)))])
            })
        })
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    /**
     image picker controller delegate method
     
     - parameter picker: image picker
     */
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        imageBG?.image = nil
        drawableView.project!.publicSave()
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - Navigation
extension ViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = SegueIdentifier(rawValue: segue.identifier!) {
            switch identifier {
            case .ConnectedUserSegue :
                connectedUsersView = segue.destinationViewController as? ConnectedUsersTableViewController
                
                if let team = Project.getLastOpen() {
                    
                    self.connectedUsersView!.team = team.team
                    self.connectedUsersView!.teamCompletion =  { (project, team) in
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.initDrawing(team, project: project)
                        })
                    }
                    self.connectedUsersView!.reload()
                }
                self.activity.stopAnimating()
                break
            case .CreateTeamSegue :
                let teamCreationVC = segue.destinationViewController as! TeamCreationViewController
                teamCreationVC.showUser = true
                teamCreationVC.completion = { (team, project) in
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.initDrawing(team, project: project!)
                        teamCreationVC.dismissViewControllerAnimated(true, completion: nil)
                        self.activity.stopAnimating()
                    })
                }
                break
            case .ShowTeamSegue :
                let navTeamVC = segue.destinationViewController as? UINavigationController
                let teamVC = navTeamVC!.viewControllers.first as? TeamTableViewController
                teamVC?.completion = { (project, team) in
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        teamVC!.dismissViewControllerAnimated(true, completion: nil)
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
    
    @IBAction func showBrushTools(sender:UIBarButtonItem) {
        if selectedTool != sender.tag {
            selectTool(sender.tag)
            selectDrawingTool(drawableView.brushTool)
        }
        else {
            selectTool(sender.tag)
            let popover : ToolsViewController = {
                $0.delegate = self
                $0.selectedTool = drawableView.getCurrentTool()
                $0.modalPresentationStyle = .FormSheet
                $0.preferredContentSize = CGSize(width: 375, height: 500)
                $0.currentColor = drawableView.color
                return $0
            }(StoryboardScene.Main.instantiateToolsVC())
           
            self.presentViewController(popover, animated: true, completion: nil)
        }
    }
    
    /**
     eraser
     
     - parameter sender: the button that send the action
     */
    @IBAction func eraser(sender:UIBarButtonItem) {
        selectTool(sender.tag)
        configureDrawableView(.eraser)
    }
    
    /**
     set the text tool
     
     - parameter sender: the button that send the action
     */
    @IBAction func textTool(sender:UIBarButtonItem) {
        selectTool(sender.tag)
        configureDrawableView(.text)
    }
    
    /**
     import a background image
     
     - parameter sender: the button that send the action
     */
    @IBAction func importBG(sender:UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .PhotoLibrary
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func showTeam(sender: AnyObject) {
        let button = sender as! UIBarButtonItem
        teamViewContainer.sendSubviewToBack(teamViewContainerBackView)
        if !teamViewContainer.hidden {
            button.image = UIImage.Asset.Ic_team.image.imageWithRenderingMode(.AlwaysTemplate)
            connectedUsersView!.segmentControl.selectedSegmentIndex = 0
            connectedUsersView!.segmentControlChanged(connectedUsersView!.segmentControl)
            teamViewContainer.hidden = false
            
            UIView.animateWithDuration(0.5, animations: {
                self.connectedUsersView!.view.layer.transform = CATransform3DMakeTranslation(0, -self.view.frame.size.height, 0)
                self.teamViewContainerBackView.backgroundColor = UIColor.draftLinkGrey().colorWithAlphaComponent(0.0)
                }, completion: { (finished) in
                    if finished {
                        self.teamViewContainer.hidden = true
                    }
            })
        }
        else {
            button.image = UIImage.Asset.Ic_team_selected.image.imageWithRenderingMode(.AlwaysTemplate)
            teamViewContainer.backgroundColor = UIColor.draftLinkGrey().colorWithAlphaComponent(0.0)
            self.teamViewContainer.hidden = false
            connectedUsersView!.view.layer.transform = CATransform3DMakeTranslation(0, -self.view.frame.size.height, 0)
            UIView.animateWithDuration(0.5) {
                self.connectedUsersView!.view.layer.transform = CATransform3DIdentity
                self.teamViewContainerBackView.backgroundColor = UIColor.draftLinkGrey().colorWithAlphaComponent(0.8)
            }
        }
    }
}