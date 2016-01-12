//
//  ColorGenerationViewController.swift
//  Mentor
//
//  Created by Alexandre barbier on 11/01/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class ColorGenerationViewController: UIViewController {
    var chosenColor : UIColor!
    private var currentSeed : CGFloat = 1.0
    private var satSeed : CGFloat = 1.0
    var teamName : String = ""
    var completion : ((team:Team,color:UIColor, colorSeed:CGFloat) -> Void)?
    private var usedSeed = [CGFloat]()
    
    @IBOutlet weak var generateColorTouch: UIButton!
    @IBOutlet weak var chooseColorButton: UIButton!
    
    var team : Team! {
        didSet {
            self.team.getUsers { (users, error) -> Void in
                for user in users {
                    user.getTeamColor(self.team, completion: { (teamColor, utColor, error) -> Void in
                        self.usedSeed.append(utColor.colorSeed)
                        if utColor.colorSeed > self.currentSeed {
                            self.currentSeed = utColor.colorSeed
                        }
                        if self.usedSeed.count == self.team.users.count {
                            self.chooseColor(self.currentSeed)
                        }
                    })
                }

            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chooseColorButton.rounded(5.0)
        self.generateColorTouch.rounded(5.0)
        self.chooseColorButton.backgroundColor = UIColor.whiteColor()
        self.generateColorTouch.backgroundColor = UIColor.whiteColor()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if team == nil {
            self.chooseColor(self.currentSeed++)
        }

    }
    
    func generateColor(seed:CGFloat) -> UIColor! {
        
        let h = seed <= 12 ? (seed / 12.0) : ((seed % 12.0) / 12.0)
        satSeed = seed <= 12 ? 1 : 6 - ((seed / 12) / 6)
        return UIColor(hue: h, saturation: satSeed, brightness: 1.0, alpha: 1.0)
    }
    
    func chooseColor(seed:CGFloat) {
        let colorRGB = generateColor(seed)
        self.chosenColor = colorRGB
        UIView.animateWithDuration(0.3) { () -> Void in
            self.view.backgroundColor = self.chosenColor
        }
    }
    
    @IBAction func chooseColorTouch(sender: AnyObject) {
        if team == nil {
            Team.create(self.teamName,color: self.chosenColor,colorSeed: self.currentSeed, completion: { (success, team) -> Void in
                self.completion?(team: team,color:self.chosenColor, colorSeed:self.currentSeed)
            })
        }
        else {
            self.completion?(team: self.team,color:self.chosenColor, colorSeed:self.currentSeed)
        }
   }
    
    @IBAction func generateColorTouch(sender: AnyObject) {
        self.chooseColor(self.currentSeed++)
    }
}
