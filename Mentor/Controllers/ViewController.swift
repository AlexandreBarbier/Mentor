
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
// TODO: Remove first team and project creation + color chooser
// TODO: fix resizing when rotate

class ViewController: UIViewController {
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: DrawableScrollView!
    @IBOutlet weak var drawableView: DrawableView!
    var buttonTools : ABExpendableButton = ABExpendableButton(orientation: .Vertical, borderColor: .blackColor(), backColor: .whiteColor())
    var imageBG : UIImageView?
    @IBOutlet weak var settingButton : UIButton!
    @IBOutlet weak var undoButton : UIButton!
    @IBOutlet weak var redoButton : UIButton!
    private var firebaseBgReference : Firebase?
    private var firebaseObserverHandle : UInt = 0
    private var canPresent = true
}

// MARK: - View lifecycle
extension ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.drawableView = self.drawableView
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
        buttonTools.addVerticalButton(["addViewIcon": addViewButton,
                                       "imageIcon"  : importBG,
                                       "settings"   : setEraser,
                                       "pen"   : pen,
                                       "marker"   : marker])

            DebugConsoleView.debugView = DebugConsoleView(inView:self.view)            

        self.view.addSubview(buttonTools)
        self.loginUser()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.prefersStatusBarHidden()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        self.canPresent = true
        super.dismissViewControllerAnimated(flag, completion: completion)
    }
}

// MARK: - Cloudkit management
extension ViewController {
    
    func loginUser() {

        DebugConsoleView.debugView.print("login method")
        CloudKitManager.availability { (available) -> Void in
            if available {
                DebugConsoleView.debugView.print("cloudKit available")
                self.activity.startAnimating()
                DebugConsoleView.debugView.print("get current user")
                let begin = NSDate()
                User.getCurrentUser({ (user, error) -> () in
                    let secDate = NSDate()
                    DebugConsoleView.debugView.print("get user completion in \(secDate.timeIntervalSinceDate(begin))")
                    guard let user = user else {
                        DebugConsoleView.debugView.errorPrint("user nil")
                        let alert = UIAlertController(title: "An error occured", message: "please restart Mentor", preferredStyle: UIAlertControllerStyle.Alert)
                        self.presentViewController(alert, animated: true, completion: nil)
                        return
                    }
                    if user.teams.count == 0 {
                        DebugConsoleView.debugView.print("team less user")
                        self.teamlessUser(user)
                    }
                    else {
                        DebugConsoleView.debugView.print("get team")
                        user.getTeams({ (teams, error) -> Void in
                            guard let team = teams.first else {
                                DebugConsoleView.debugView.errorPrint("team error \(error)")
                                return
                            }
                            DebugConsoleView.debugView.print("team received")
                            if team.projects.count == 0 {
                                DebugConsoleView.debugView.warningPrint("project less team")
                                self.projectlessTeam(team)
                            }
                            else {
                                DebugConsoleView.debugView.print("get project")
                                team.getProjects({ (projects, error) -> Void in
                                    guard let project = projects.first else {
                                        DebugConsoleView.debugView.errorPrint("project error \(error)")
                                        return
                                    }
                                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                        self.initDrawing(team, project: project)
                                        self.usernamelessUser(KCurrentUser!)
                                        
                                    })
                                })
                            }
                        })
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
    
    func usernamelessUser(user:User) {
        if user.username == "" {
            let alert = UIAlertController(title: "You need a username", message: "Chouse your username", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                textField.placeholder = "User name"
            })
            alert.addAction(UIAlertAction(title: "Create", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                guard let textField = alert.textFields!.first else {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        alert.dismissViewControllerAnimated(false, completion: nil)
                        self.usernamelessUser(user)
                    })
                    return
                }
                switch textField.text! {
                case "" :
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        alert.dismissViewControllerAnimated(false, completion: nil)
                        self.usernamelessUser(user)
                    })
                    break
                default :
                    user.username = textField.text!
                    user.publicSave()
                    break
                }
            }))
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            self.activity.stopAnimating()
        })
    }
    
    func initFirebase() -> Void {
        if let firebaseBgReference = firebaseBgReference {
            firebaseBgReference.removeObserverWithHandle(firebaseObserverHandle)
        }
        firebaseBgReference = Firebase(url: "\(Constants.NetworkURL.firebase.rawValue)\(drawableView.project!.recordName)/back")
        firebaseObserverHandle = firebaseBgReference!.observeEventType(FEventType.ChildChanged, withBlock: { (snap) -> Void in
            self.drawableView.project!.refresh({ (updateObject:Project?) -> Void in
                if let update = updateObject {
                    self.drawableView.project = update
                    self.setBG(self.drawableView.project!)
                }
            })
        })
    }
    
    func projectlessTeam(team:Team) {
        let alert = UIAlertController(title: "You need a project", message: "Create a project", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "New project name"
        })
        alert.addAction(UIAlertAction(title: "Create", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            guard let textField = alert.textFields!.first else {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    alert.dismissViewControllerAnimated(false, completion: nil)
                    self.projectlessTeam(team)
                })
                return
            }
            switch textField.text! {
            case "" :
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    alert.dismissViewControllerAnimated(false, completion: nil)
                    self.projectlessTeam(team)
                })
                break
            default :
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    let _ = Project.create(textField.text!, team: team, completion: { (project, team) -> Void in
                        self.initDrawing(team, project: project)
                        self.usernamelessUser(KCurrentUser!)
                    })
                })
                break
            }
        }))
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func teamlessUser(user:User) {
        let alert = UIAlertController(title: "You need a team", message: "Create or join a team", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "New team name or token"
        })
        alert.addAction(UIAlertAction(title: "Create", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            guard let textField = alert.textFields!.first else {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                })
                return
            }
            switch textField.text! {
            case "" :
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    alert.dismissViewControllerAnimated(false, completion: nil)
                    self.teamlessUser(user)
                })
                break
            default :
                let colorAlert = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ColorGeneratorVC") as! ColorGenerationViewController
                colorAlert.teamName = textField.text!
                colorAlert.debug = true
                colorAlert.completion = { (team, color, colorSeed) in
                    colorAlert.dismissViewControllerAnimated(true, completion: { () -> Void in
                        self.projectlessTeam(team)
                    })

                }
                self.presentViewController(colorAlert, animated: true, completion: nil)
                break
            }
        }))
        alert.addAction(UIAlertAction(title: "Join", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            guard let textField = alert.textFields!.first else {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                })
                return
            }
            switch textField.text! {
            case "" :
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    alert.dismissViewControllerAnimated(false, completion: nil)
                    self.teamlessUser(user)
                })
                break
            default :
                Team.get(textField.text!, completion: { (team, error) -> Void in
                    guard let team = team else {
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            alert.dismissViewControllerAnimated(false, completion: nil)
                            self.teamlessUser(user)
                        })
                        return
                    }
                    //TODO: Choose color
                    let colorAlert = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ColorGeneratorVC") as! ColorGenerationViewController
                    colorAlert.team = team
                    colorAlert.debug = true
                    colorAlert.completion = { (team, color, colorSeed) in
                         colorAlert.dismissViewControllerAnimated(true, completion:nil)
                        user.addTeam(team, color:color, colorSeed: colorSeed)
                        
                        team.getProjects({ (projects, error) -> Void in
                            guard let project = projects.first else {
                                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                    alert.dismissViewControllerAnimated(false, completion: nil)
                                    self.projectlessTeam(team)
                                })
                                return
                            }
                            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                self.initDrawing(team, project: project)
                            })
                    })
                    }
                    self.presentViewController(colorAlert, animated: true, completion: nil)

                })
                break
            }
        }))
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
// MARK: - Drawing initialisation
extension ViewController {
    func setDrawingColor(team:Team) {
        KCurrentUser!.getTeamColor(team, completion: { (teamColor,userTeamColor:UserTeamColor, error) -> Void in
            self.drawableView.color = teamColor == nil ? UIColor.greenColor() : teamColor
        })
    }
    
    func setBG(project:Project) {
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
            if let bg = project.background {
                if self.imageBG == nil {
                    self.imageBG = UIImageView(image: UIImage(data: NSData(contentsOfFile: bg.fileURL.path!)!))
                    self.imageBG!.autoresizingMask = [.FlexibleHeight,.FlexibleHeight]
                    self.scrollView.insertSubview(self.imageBG!, atIndex: 0)
                    self.imageBG!.contentMode = .ScaleAspectFill
                }
                else {
                    self.imageBG!.image = UIImage(data: NSData(contentsOfFile: bg.fileURL.path!)!)
                }
                
                self.imageBG!.frame = self.drawableView.frame
                
            }
            else {
                if self.imageBG != nil {
                    self.imageBG!.image = nil
                    self.imageBG!.frame = self.drawableView.frame
                }
            }
        })
    }
    
    func initDrawing(team:Team, project:Project) {
        self.setDrawingColor(team)
        self.drawableView.project = project
        self.initFirebase()
        self.scrollView.contentSize = self.drawableView.frame.size
        self.setBG(project)
    }
}

// MARK: - background management
extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func importBG(sender:UIButton) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .PhotoLibrary
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
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
                self.firebaseBgReference!.updateChildValues(["bg":NSNumber(unsignedInt:arc4random())])
            })
        })
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.imageBG?.image = nil
        drawableView.project!.publicSave()
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - Gestures
extension ViewController {
    func setEraser(sender:UIButton) {
        drawableView.eraser = !drawableView.eraser
    }
}

// MARK: - Drawing settings
extension ViewController {
    func setBrushSize(sender:UIButton) {
        drawableView.lineWidth = 3.0
    }
}

// MARK: - tools method
extension ViewController {
    
    @IBAction func undoTouch(sender:UIButton) {
        self.drawableView.undo()
    }
    
    @IBAction func redoTouch(sender:UIButton) {
        self.drawableView.redo()
    }
    
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
    }
    
    func eraser(sender:UIButton) {
        drawableView.eraser = true
    }
    func pen(sender:UIButton) {
        drawableView.lineWidth = 2.0
        drawableView.pen = true
    }
    func marker(sender:UIButton) {
        drawableView.lineWidth = 15.0
        drawableView.marker = true

    }
    
    func addViewButton(sender:UIButton) {
        let k = UIAlertController(title: "Clear", message: "Remove everything", preferredStyle: UIAlertControllerStyle.Alert)
        k.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            
        }))
        k.addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            k.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(k, animated: true, completion: nil)
    }
}