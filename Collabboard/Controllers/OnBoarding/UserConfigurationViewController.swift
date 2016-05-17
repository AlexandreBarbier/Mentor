//
//  UserConfigurationViewController.swift
//  Collabboard
//
//  Created by Alexandre barbier on 17/05/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class ColorSelectionCell : UICollectionViewCell {
    @IBOutlet var selectedImage: UIImageView!
    override func awakeFromNib() {
        selectedImage.image = selectedImage.image?.imageWithRenderingMode(.AlwaysTemplate)
        selectedImage.tintColor = UIColor.whiteColor()
    }
}

class UserConfigurationViewController: UIViewController {
    @IBOutlet var usernameTextfield: DFTextField!
    @IBOutlet var colorCollectionView: UICollectionView!
    @IBOutlet var createButton: UIButton!
    
    var teamName = ""
    var projectName = ""
    var colorArray : [UIColor] = []
    var chosenColor = 0
}

// MARK: - View lifecycle
extension UserConfigurationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextfield.padding = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
        usernameTextfield.setup(border: UIColor.draftLinkBlueColor(), innerColor: UIColor.draftLinkDarkBlueColor(), cornerRadius: 5)
        usernameTextfield.rounded(5)
        createButton.backgroundColor = UIColor.draftLinkBlueColor()
        
        ColorGenerator.CGSharedInstance.currentSeed = 0.0
        
        for _ in 0 ..< 5 {
            self.colorArray.append(ColorGenerator.CGSharedInstance.getNextColor()!)
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.colorCollectionView.reloadData()
                
            })
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UserConfigurationViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text != "" {
            textField.resignFirstResponder()
        }
        return false
    }
}

// MARK: - Collection view
extension UserConfigurationViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ColorCellIdentifier", forIndexPath: indexPath) as! ColorSelectionCell
        cell.backgroundColor = colorArray[indexPath.row]
        if indexPath.row == chosenColor {
            cell.selectedImage.hidden = false
        }
        else {
            cell.selectedImage.hidden = true
        }
        cell.rounded()
        cell.border(UIColor.whiteColor(), width: 2.0)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 20
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        chosenColor = indexPath.row
        collectionView.reloadData()
    }
}

// MARK: - Navigation
extension UserConfigurationViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueId = StoryboardSegue.OnBoarding(rawValue: segue.identifier!) {
            switch segueId {
            case .ShowDraftSegue:
                break
            default:
                break
            }
        }
    }
}

// MARK: - Actions
extension UserConfigurationViewController {
    
    @IBAction func onCreateTouch(sender: AnyObject) {
        User.currentUser!.username = usernameTextfield.text!
        Team.create(teamName, color: colorArray[chosenColor], colorSeed: ColorGenerator.CGSharedInstance.currentSeed, completion: { (success, team) -> Void in
            Project.create(self.projectName, team: team, completion: { (project, team) -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    
                    User.currentUser!.addTeam(team, color: self.colorArray[self.chosenColor], colorSeed: ColorGenerator.CGSharedInstance.currentSeed, completion: {
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            project.setLastOpenForTeam(team)
                            NSUserDefaults().setBool(true, forKey: "userConnect")
                            self.performSegue(StoryboardSegue.OnBoarding.ShowDraftSegue)
                        })
                    })
                })
            })
        })
    }
}