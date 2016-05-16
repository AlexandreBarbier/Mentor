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
import Firebase

// MARK: - ViewController declaration
// TODO: fix resizing when rotate

private enum SegueIdentifier : String {
    case ShowTeamSegue
    case CreateTeamSegue
    case ConnectedUserSegue
}

class ViewController: UIViewController {
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: DrawableScrollView!
    @IBOutlet weak var drawableView: DrawableView!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var teamViewContainer: UIView!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet var bottomBarButtons: [UIBarButtonItem]!
    @IBOutlet weak var logoItem: UIBarButtonItem!
    
    private var connectedUsersView : ConnectedUsersTableViewController?
    private var interfaceIsVisible = true
    private var canDownloadBG = true
    private var selectedTool = 0
    var imageBG : UIImageView?
    
}

// MARK: - View lifecycle
extension ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topToolbar.tintColor = UIColor.draftLinkGreyColor()
        logoItem.image = UIImage.Asset.Topbar_logo.image.imageWithRenderingMode(.AlwaysOriginal)
        selectTool(0)
        teamViewContainer.hidden = true
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
    
    @IBAction func hideInterface(sender: AnyObject) {
        if drawableView.getCurrentTool() == .text {
            let tap = sender as! UITapGestureRecognizer
            drawableView.addText(tap)
            return
        }
        let alpha = 1 - bottomToolBar.alpha
        if alpha == 1 {
            bottomToolBar.hidden = interfaceIsVisible
            topToolbar.hidden = interfaceIsVisible
            progressView.hidden = interfaceIsVisible ? interfaceIsVisible : self.progressView.progress == 1.0
            
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
        CloudKitManager.availability { (available) -> Void in
            if available {
                //self.activity.startAnimating()
                User.getCurrentUser({ (user, error) -> () in
                    guard let user = user else {
                        let alert = UIAlertController(title: "An error occured", message: "please restart Mentor", preferredStyle: UIAlertControllerStyle.Alert)
                        self.presentViewController(alert, animated: true, completion: nil)
                        return
                    }
                    // here we assume that a user always have at least one team and one project this is ensure by the login process and the fact that if you have only one team or one project you are not able to delete it
                    if user.teams.count == 0 {
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.performSegueWithIdentifier(StoryboardSegue.Main.CreateTeamSegue.rawValue, sender: self)
                        })
                    }
                    else {
                        if let lastOpenedteamProject = Project.getLastOpen() {
                            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                self.initDrawing(lastOpenedteamProject.team!, project: lastOpenedteamProject.project!)
                            })
                        }
                        else {
                            user.getTeams({ (teams, local, error) -> Void in
                                if !local {
                                    if let team = teams.first {
                                        team.getProjects({ (projects, local, error) -> Void in
                                            if let project = projects.first {
                                                self.initDrawing(team, project: project)
                                            }
                                        })
                                        if let connectedUser = self.connectedUsersView {
                                            connectedUser.team = team
                                            connectedUser.teamCompletion =  { (project, team) in
                                                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                                    self.initDrawing(team, project: project)
                                                })
                                            }
                                            connectedUser.reload()
                                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                                self.activity.stopAnimating()
                                            })
                                            
                                        }
                                    }
                                }
                            })
                            self.activity.stopAnimating()
                        }
                    }
                })
            }
            else {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    let alert = UIAlertController(title: "iCloud account required", message: "To use this app you need to be connected to your iCloud account", preferredStyle: UIAlertControllerStyle.Alert)
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
    /**
     firebase initialisation for background change
     
     - parameter project: current project
     */
    func initFirebase(team: Team, project:Project) -> Void {
        cbFirebase.setupWithTeam(team, project: project)
        cbFirebase.firebaseBackgroundObserverHandle = cbFirebase.background!.observeEventType(FEventType.ChildChanged, withBlock: { (snap) -> Void in
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
            item.tintColor = item.tag == index ?  UIColor.draftLinkBlueColor() : UIColor.draftLinkGreyColor()
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
    
    func toolsViewChangeUserColor(toolsView:ToolsViewController, color: UIColor) {
        //TODO: change user color
    }
}

// MARK: - Drawing initialisation
extension ViewController {
    
    /**
     set the drawing color
     
     - parameter team: current team
     */
    func setDrawingColor(team:Team) {
        User.currentUser!.getTeamColor(team, completion: { (teamColor,userTeamColor:UserTeamColor, error) -> Void in
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
                        self.imageBG = UIImageView(image: UIImage(data: data))
                        self.imageBG!.autoresizingMask = [.FlexibleHeight,.FlexibleHeight]
                        self.scrollView.insertSubview(self.imageBG!, atIndex: 0)
                        self.imageBG!.contentMode = .ScaleAspectFill
                        self.imageBG!.frame = self.drawableView.frame
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
            imageBG = UIImageView(image: info[UIImagePickerControllerOriginalImage] as? UIImage)
            imageBG!.contentMode = .ScaleAspectFill
            imageBG!.frame = view.bounds
            imageBG!.autoresizingMask = [.FlexibleHeight,.FlexibleHeight]
            scrollView.insertSubview(imageBG!, atIndex: 0)
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
            let popover = StoryboardScene.Main.instantiateToolsVC()
            popover.delegate = self
            popover.selectedTool = drawableView.getCurrentTool()
            popover.modalPresentationStyle = .FormSheet
            popover.preferredContentSize = CGSize(width: 300, height: 400)
            popover.currentColor = drawableView.color
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
        if !self.teamViewContainer.hidden {
            button.image = UIImage.Asset.Ic_team.image.imageWithRenderingMode(.AlwaysTemplate)
            connectedUsersView!.segmentControl.selectedSegmentIndex = 0
            connectedUsersView!.segmentControlChanged(connectedUsersView!.segmentControl)
            self.teamViewContainer.hidden = false
            
            UIView.animateWithDuration(0.5, animations: {
                self.connectedUsersView!.view.layer.transform = CATransform3DMakeTranslation(0, -self.view.frame.size.height, 0)
                self.teamViewContainer.backgroundColor = UIColor.draftLinkGreyColor().colorWithAlphaComponent(0.0)
                }, completion: { (finished) in
                    if finished {
                        self.teamViewContainer.hidden = true
                    }
            })
        }
        else {
            button.image = UIImage.Asset.Ic_team_selected.image.imageWithRenderingMode(.AlwaysTemplate)
            teamViewContainer.backgroundColor = UIColor.draftLinkGreyColor().colorWithAlphaComponent(0.0)
            self.teamViewContainer.hidden = false
            connectedUsersView!.view.layer.transform = CATransform3DMakeTranslation(0, -self.view.frame.size.height, 0)
            UIView.animateWithDuration(0.5) {
                self.connectedUsersView!.view.layer.transform = CATransform3DIdentity
                self.teamViewContainer.backgroundColor = UIColor.draftLinkGreyColor().colorWithAlphaComponent(0.8)
                }
        }
    }
}