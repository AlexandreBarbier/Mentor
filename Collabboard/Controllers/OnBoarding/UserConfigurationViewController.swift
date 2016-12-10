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
        selectedImage.image = selectedImage.image?.withRenderingMode(.alwaysTemplate)
        selectedImage.tintColor = UIColor.white
    }
}

class UserConfigurationViewController: UIViewController {
    @IBOutlet var usernameTextfield: DFTextField! {
        didSet {
            usernameTextfield.padding = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
            usernameTextfield.setup(border: UIColor.draftLinkBlue, innerColor: UIColor.draftLinkDarkBlue, cornerRadius: 5)
        }
    }
    @IBOutlet var colorCollectionView: UICollectionView!
    @IBOutlet var getStartedLabel: UILabel! {
        didSet {
            getStartedLabel.textColor = UIColor.draftLinkBlue
            getStartedLabel.font = UIFont.Kalam(.bold, size: 30)
        }
    }
    
    @IBOutlet var createButton: UIButton! {
        didSet {
            createButton.backgroundColor = UIColor.draftLinkBlue
            createButton.rounded(5)
            createButton.titleLabel?.font = UIFont.Roboto(.regular, size: 20)
        }
    }
    @IBOutlet var pickColorLabel: UILabel! {
        didSet {
            pickColorLabel.textColor = UIColor.draftLinkDarkBlue
            pickColorLabel.font = UIFont.Roboto(.regular, size: 20)
        }
    }
    @IBOutlet var createYourProfileLabel: UILabel! {
        didSet {
            createYourProfileLabel.textColor = UIColor.draftLinkDarkBlue
            createYourProfileLabel.font = UIFont.Roboto(.regular, size: 24)
        }
    }
    
    var teamName = ""
    var projectName = ""
    var colorArray : [UIColor] = []
    var chosenColor = 0
}

// MARK: - View lifecycle
extension UserConfigurationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        ColorGenerator.instance.currentSeed = 0.0
        
        for _ in 0 ..< 5 {
            self.colorArray.append(ColorGenerator.instance.getNextColor()!.color)
            OperationQueue.main.addOperation({
                self.colorCollectionView.reloadData()
                
            })
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension UserConfigurationViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            textField.resignFirstResponder()
        }
        return false
    }
}

// MARK: - Collection view
extension UserConfigurationViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCellIdentifier", for: indexPath) as! ColorSelectionCell
        cell.backgroundColor = colorArray[(indexPath as NSIndexPath).row]
        if (indexPath as NSIndexPath).row == chosenColor {
            cell.selectedImage.isHidden = false
        }
        else {
            cell.selectedImage.isHidden = true
        }
        cell.rounded()
        cell.border(UIColor.white, width: 2.0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        chosenColor = (indexPath as NSIndexPath).row
        collectionView.reloadData()
    }
}

// MARK: - Navigation
extension UserConfigurationViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = StoryboardSegue.OnBoarding(rawValue: segue.identifier!) {
            switch segueId {
            case .showDraftSegue:
                break
            default:
                break
            }
        }
    }
}

// MARK: - Actions
extension UserConfigurationViewController {
    
    @IBAction func onCreateTouch(_ sender: AnyObject) {
        guard let user = User.currentUser, let username = usernameTextfield.text, username != "" else {
            return
        }
        user.username = username
        Team.create(teamName, color: colorArray[chosenColor], colorSeed: ColorGenerator.instance.currentSeed, completion: { (success, team) -> Void in
            guard success else {
                print("error team creation")
                return
            }
            Project.create(self.projectName, team: team, completion: { (project, team) -> Void in
                DispatchQueue.main.async {
                    project.setLastOpenForTeam(team)
                    UserDefaults().set(true, forKey: "userConnect")
                    self.performSegue(withIdentifier: StoryboardSegue.OnBoarding.showDraftSegue.rawValue, sender: self)
                }
            })
        })
    }
}
