
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

class ViewController: UIViewController {
    @IBOutlet weak var progressView: UIProgressView!
    var connectedUsersView: ConnectedUsersTableViewController!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: DrawableScrollView!
    @IBOutlet weak var drawableView: DrawableView!
    var buttonTools : ABExpendableButton = ABExpendableButton(orientation: .Vertical, borderColor: .blackColor(), backColor: .whiteColor())
    var imageBG : UIImageView?
    private var interfaceIsVisible = true
    @IBOutlet weak var settingButton : UIButton!
    @IBOutlet weak var undoButton : UIButton!
    @IBOutlet weak var redoButton : UIButton!
    private var downloadBG = true
}

// MARK: - View lifecycle
extension ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.connectedUsersView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ConnectedUsersVC") as! ConnectedUsersTableViewController
        self.connectedUsersView.view.frame = CGRect(origin: CGPoint(x: self.view.frame.size.width - 58, y: 0), size: self.view.frame.size)
        self.view.addSubview(self.connectedUsersView.view)
        scrollView.drawableView = self.drawableView
        self.progressView.progress = 0.0
        drawableView.loadingProgressBlock = {(progress, current, total) in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.progressView.progress = Float(progress)
                self.progressView.hidden = self.progressView.progress == 1.0
            })
            
        }
        settingButton.border(.blackColor(), width: 2.0)
        settingButton.circle()
        settingButton.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        redoButton.border(UIColor.blackColor(), width: 1.0)
        undoButton.border(UIColor.blackColor(), width: 1.0)
        undoButton.rounded()
        redoButton.rounded()
        activity.rounded()
        buttonTools.verticaleDirection = .Up
        buttonTools.frame.origin = CGPoint(x: self.view.frame.width - buttonTools.frame.width,
            y: self.view.frame.height - buttonTools.frame.height)
        buttonTools.addVerticalButton(["addViewIcon": textTool,
            "imageIcon"  : importBG,
            "settings"   : setEraser,
            "pen"        : pen,
            "marker"     : marker])
        
        DebugConsoleView.debugView = DebugConsoleView(inView:self.view)

        self.view.addSubview(buttonTools)
        self.prefersStatusBarHidden()
        self.loginUser()
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
        if drawableView.text {
            let tap = sender as! UITapGestureRecognizer
            drawableView.addText(tap)
                    drawableView.text = false
            return
        }
        let alpha = 1 - self.undoButton.alpha
        if alpha == 1 {
            self.undoButton.hidden = self.interfaceIsVisible
            self.redoButton.hidden = self.interfaceIsVisible
            self.buttonTools.hidden = self.interfaceIsVisible
            self.connectedUsersView.view.hidden = self.interfaceIsVisible
            self.settingButton.hidden = self.interfaceIsVisible
        }
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.undoButton.alpha = alpha
            self.redoButton.alpha = alpha
            self.buttonTools.alpha = alpha
            self.connectedUsersView.view.alpha = alpha
            self.settingButton.alpha = alpha
            }) { (finished) -> Void in
                if alpha != 1 {
                    self.undoButton.hidden = self.interfaceIsVisible
                    self.redoButton.hidden = self.interfaceIsVisible
                    self.buttonTools.hidden = self.interfaceIsVisible
                    self.connectedUsersView.view.hidden = self.interfaceIsVisible
                    self.settingButton.hidden = self.interfaceIsVisible
                }
        }
        self.interfaceIsVisible = !self.interfaceIsVisible
    }
}

// MARK: - Cloudkit management
extension ViewController {
    /**
     log the current user into iCloud
     */
    func loginUser() {
        DebugConsoleView.debugView.print("login method")
        CloudKitManager.availability { (available) -> Void in
            if available {
                DebugConsoleView.debugView.print("cloudKit available")
                self.activity.startAnimating()
                DebugConsoleView.debugView.print("get current user")
                User.getCurrentUser({ (user, error) -> () in
                    guard let user = user else {
                        DebugConsoleView.debugView.errorPrint("user nil")
                        let alert = UIAlertController(title: "An error occured", message: "please restart Mentor", preferredStyle: UIAlertControllerStyle.Alert)
                        self.presentViewController(alert, animated: true, completion: nil)
                        return
                    }
                    // here we assume that a user always have at least one team and one project this is ensure by the login process and the fact that if you have only one team or one project you are not able to delete it
                    if user.teams.count == 0 {
                        DebugConsoleView.debugView.print("team less user")
                        self.performSegueWithIdentifier("CreateTeamSegue", sender: self)
                    }
                    else {
                        DebugConsoleView.debugView.print("get team")
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
                                    }
                                }
                            })
                            self.activity.stopAnimating()
                        }
                    }
                })
            }
            else {
                DebugConsoleView.debugView.errorPrint("cloudKit unavailable")
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
            if self.downloadBG {
                self.drawableView.project!.refresh({ (updateObject:Project?) -> Void in
                    if let update = updateObject {
                        self.drawableView.project = update
                        self.setBG(self.drawableView.project!)
                    }
                })
            }
            self.downloadBG = true
        })
    }
}

// MARK: - Drawing initialisation
extension ViewController {
    
    /**
     set the drawing color
     
     - parameter team: current team
     */
    func setDrawingColor(team:Team) {
        KCurrentUser!.getTeamColor(team, completion: { (teamColor,userTeamColor:UserTeamColor, error) -> Void in
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
                    self.imageBG!.image = UIImage(data: NSData(contentsOfFile: bg.fileURL.path!)!)
                    self.imageBG!.frame = self.drawableView.frame
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
        self.setDrawingColor(team)
        self.drawableView.project = project
        self.connectedUsersView.team = team
        
        self.initFirebase(team, project: project)
        self.scrollView.contentSize = self.drawableView.frame.size
        self.setBG(project)
        self.activity.stopAnimating()
    }
}

// MARK: - background management
extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /**
     import a background image
     
     - parameter sender: the button that send the action
     */
    func importBG(sender:UIButton) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .PhotoLibrary
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    
    /**
     image picker controller delegate method
     
     - parameter picker: image picker
     - parameter info:   data from the image picker
     */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if self.imageBG == nil {
            imageBG = UIImageView(image: info[UIImagePickerControllerOriginalImage] as? UIImage)
            imageBG!.contentMode = .ScaleAspectFill
            imageBG!.frame = self.view.bounds
            imageBG!.autoresizingMask = [.FlexibleHeight,.FlexibleHeight]
            self.scrollView.insertSubview(imageBG!, atIndex: 0)
        }
        else {
            imageBG?.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        drawableView.project!.saveBackground((imageBG?.image)!,completion: { () in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                DebugConsoleView.debugView.print("bg uploaded")
                self.downloadBG = false
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
        self.imageBG?.image = nil
        drawableView.project!.publicSave()
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - Drawing settings
extension ViewController {
    
    func setBrushSize(sender:UIButton) {
        drawableView.lineWidth = 3.0
    }
    
    func setEraser(sender:UIButton) {
        drawableView.eraser = !drawableView.eraser
    }
}

// MARK: - tools method
extension ViewController {
    /**
     undo button touch
     
     - parameter sender: undo button
     */
    @IBAction func undoTouch(sender:UIButton) {
        self.drawableView.undo()
    }
    /**
     redo button touch
     
     - parameter sender: redo button
     */
    @IBAction func redoTouch(sender:UIButton) {
        self.drawableView.redo()
    }
    
    //TODO: put segue identifier in Constant
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowTeamSegue" {
            let navTeamVC = segue.destinationViewController as? UINavigationController
            let teamVC = navTeamVC!.viewControllers.first as? TeamTableViewController
            teamVC?.completion = { (project, team) in
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    teamVC!.dismissViewControllerAnimated(true, completion: nil)
                    
                    self.initDrawing(team, project: project)
                })
                
            }
        }
        if segue.identifier == "CreateTeamSegue" {
            let teamCreationVC = segue.destinationViewController as! TeamCreationViewController
            teamCreationVC.showUser = true
            teamCreationVC.completion = { (team, project) in
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.initDrawing(team, project: project!)
                    teamCreationVC.dismissViewControllerAnimated(true, completion: nil)
                    self.activity.stopAnimating()
                })
            }
        }
        if segue.identifier == "ConnectedUserSegue" {
            self.connectedUsersView = segue.destinationViewController as! ConnectedUsersTableViewController
        }
    }
    /**
     eraser
     
     - parameter sender: the button that send the action
     */
    func eraser(sender:UIButton) {
        drawableView.eraser = true
    }
    
    /**
     set the pen tool
     
     - parameter sender: the button that send the action
     */
    func pen(sender:UIButton) {
        drawableView.lineWidth = 2.0
        drawableView.pen = false
        drawableView.text = false
        drawableView.eraser = false
    }
    
    /**
     set the marker tool
     
     - parameter sender: the button that send the action
     */
    func marker(sender:UIButton) {
        drawableView.lineWidth = 15.0
        drawableView.marker = true
        drawableView.text = false
        drawableView.eraser = false
    }
    
    func textTool(sender:UIButton) {
        drawableView.text = true
        drawableView.pen = false
        drawableView.marker = false
        drawableView.eraser = false
    }
    
    func addViewButton(sender:UIButton) {
        let k = UIAlertController(title: "Clear", message: "Remove everything", preferredStyle: UIAlertControllerStyle.Alert)
        k.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            self.drawableView.clear()
        }))
        k.addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            k.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(k, animated: true, completion: nil)
    }
}