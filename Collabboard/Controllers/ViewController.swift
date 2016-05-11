
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

class ViewController: UIViewController, ToolsViewDelegate {
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: DrawableScrollView!
    @IBOutlet weak var drawableView: DrawableView!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    
    private var interfaceIsVisible = true
    private var canDownloadBG = true
    var imageBG : UIImageView?
    var connectedUsersView: ConnectedUsersTableViewController!
}

// MARK: - View lifecycle
extension ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectedUsersView = StoryboardScene.Main.instantiateConnectedUsersVC()
        let panelSize = CGSize(width: view.frame.size.width , height: view.frame.size.height - 44)
        connectedUsersView.view.frame = CGRect(origin: CGPoint(x: view.frame.size.width - 58, y: 0), size: panelSize)
        view.addSubview(connectedUsersView.view)
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
        if drawableView.text {
            let tap = sender as! UITapGestureRecognizer
            drawableView.addText(tap)
            drawableView.text = false
            return
        }
        let alpha = 1 - bottomToolBar.alpha
        if alpha == 1 {
            bottomToolBar.hidden = interfaceIsVisible
            connectedUsersView.view.hidden = interfaceIsVisible
        }
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.bottomToolBar.alpha = alpha
            self.connectedUsersView.view.alpha = alpha
            
        }) { (finished) -> Void in
            if alpha != 1 {
                self.bottomToolBar.hidden = self.interfaceIsVisible
                self.connectedUsersView.view.hidden = self.interfaceIsVisible
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
                    self.connectedUsersView.teamCompletion =  { (project, team) in
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.initDrawing(team, project: project)
                        })
                        
                    }
                    // here we assume that a user always have at least one team and one project this is ensure by the login process and the fact that if you have only one team or one project you are not able to delete it
                    if user.teams.count == 0 {
                        DebugConsoleView.debugView.print("team less user")
                        self.performSegueWithIdentifier(StoryboardSegue.Main.CreateTeamSegue.rawValue, sender: self)
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

// MARK: - tools view delegate

extension ViewController {
    func didSelectTools(popover:ToolsCollectionViewController,tool: Tool) {
        switch tool {
        case .marker :
            marker()
            break
        case .pen :
            pen()
            break
        }
        popover.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func changeBrushSize(popover:ToolsCollectionViewController, size: CGFloat) {
        drawableView.lineWidth = size
        popover.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func changeUserColor(popover:ToolsCollectionViewController, color: UIColor) {
        popover.dismissViewControllerAnimated(true, completion: nil)
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
        connectedUsersView.team = team
        
        initFirebase(team, project: project)
        scrollView.contentSize = drawableView.frame.size
        setBG(project)
        activity.stopAnimating()
    }
}

// MARK: - background management
extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /**
     import a background image
     
     - parameter sender: the button that send the action
     */
    @IBAction func importBG(sender:AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .PhotoLibrary
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
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
                DebugConsoleView.debugView.print("bg uploaded")
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

// MARK: - Drawing settings
extension ViewController {
    
    func setBrushSize(sender:UIButton) {
        drawableView.lineWidth = 3.0
    }
    
    func setEraser(sender:UIButton) {
        drawableView.eraser = !drawableView.eraser
    }
}

// MARK: - Navigation

extension ViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = SegueIdentifier(rawValue: segue.identifier!) {
            switch identifier {
            case .ConnectedUserSegue :
                connectedUsersView = segue.destinationViewController as! ConnectedUsersTableViewController
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


// MARK: - tools method
extension ViewController {
    
    private func configureDrawableView(lineWidth:CGFloat, text: Bool, pen: Bool, marker:Bool, eraser: Bool) {
        drawableView.lineWidth = lineWidth
        drawableView.marker = marker
        drawableView.pen = pen
        drawableView.text = text
        drawableView.eraser = eraser
    }
    
    /**
     eraser
     
     - parameter sender: the button that send the action
     */
    @IBAction func eraser(sender:AnyObject) {
        drawableView.eraser = true
    }
    
    @IBAction func showBrushTools(sender:UIBarButtonItem) {
        let popover = StoryboardScene.Main.instantiateToolsVC()
        popover.currentColor = drawableView.color
        self.presentViewController(popover, animated: true, completion: nil)
    }
    /**
     set the pen tool
     
     - parameter sender: the button that send the action
     */
    func pen() {
        configureDrawableView(2.0, text: false, pen: true, marker: false, eraser: false)
    }
    /**
     set the marker tool
     
     - parameter sender: the button that send the action
     */
    func marker() {
        configureDrawableView(15.0, text: false, pen: false, marker: true, eraser: false)
    }
    
    /**
     set the text tool
     
     - parameter sender: the button that send the action
     */
    @IBAction func textTool(sender:AnyObject) {
        configureDrawableView(0.0, text: true, pen: false, marker: false, eraser: false)
    }
}