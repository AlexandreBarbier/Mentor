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
    @IBOutlet var getStartedLabel: UILabel!
    @IBOutlet var createButton: UIButton!
    @IBOutlet var pickColorLabel: UILabel!
    @IBOutlet var createYourProfileLabel: UILabel!
    
    var teamName = ""
    var projectName = ""
    var colorArray : [UIColor] = []
    var chosenColor = 0
}

// MARK: - View lifecycle
extension UserConfigurationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getStartedLabel.textColor = UIColor.draftLinkBlue()
        getStartedLabel.font = UIFont.Kalam(.Bold, size: 30)
        pickColorLabel.textColor = UIColor.draftLinkDarkBlue()
        pickColorLabel.font = UIFont.Roboto(.Regular, size: 20)
        createYourProfileLabel.textColor = UIColor.draftLinkDarkBlue()
        createYourProfileLabel.font = UIFont.Roboto(.Regular, size: 24)
        
        usernameTextfield.padding = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
        usernameTextfield.setup(border: UIColor.draftLinkBlue(), innerColor: UIColor.draftLinkDarkBlue(), cornerRadius: 5)
        createButton.backgroundColor = UIColor.draftLinkBlue()
        createButton.rounded(5)
        createButton.titleLabel?.font = UIFont.Roboto(.Regular, size: 20)
        
        ColorGenerator.CGSharedInstance.currentSeed = 0.0
        
        for _ in 0 ..< 5 {
            self.colorArray.append(ColorGenerator.CGSharedInstance.getNextColor()!.color)
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.colorCollectionView.reloadData()
                
            })
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        guard let user = User.currentUser where usernameTextfield.text != "" else {
            return
        }
        user.username = usernameTextfield.text!
        Team.create(teamName, color: colorArray[chosenColor], colorSeed: ColorGenerator.CGSharedInstance.currentSeed, completion: { (success, team) -> Void in
            
            Project.create(self.projectName, team: team, completion: { (project, team) -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        project.setLastOpenForTeam(team)
                        NSUserDefaults().setBool(true, forKey: "userConnect")
                        self.performSegue(StoryboardSegue.OnBoarding.ShowDraftSegue)
                    })
                })
            })
        })
    }
}