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
    var currentSeed : CGFloat = 1.0
    private var satSeed : CGFloat = 1.0
    var teamName : String = ""
    var completion : ((team:Team,color:UIColor, colorSeed:CGFloat) -> Void)?
    private var usedSeed = [CGFloat]()
    var debug = false
    @IBOutlet weak var backView: UIView!
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
                            self.chooseColor()
                        }
                    })
                }

            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.generateColorTouch.rounded(5.0)

        self.generateColorTouch.backgroundColor = UIColor.whiteColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if team == nil {
            self.chooseColor()
        }
        if debug {
            self.chooseColor()
            Team.create(self.teamName,color: self.chosenColor,colorSeed: self.currentSeed, completion: { (success, team) -> Void in
                self.completion?(team: team,color:self.chosenColor, colorSeed:self.currentSeed)
            })
        }
    }
    
    func generateColor(seed:CGFloat) -> UIColor! {
        let h = seed <= 12 ? (seed / 12.0) : ((seed % 12.0) / 12.0)
        satSeed = seed <= 12 ? 1 : 1 - ((seed % 12) / 12)
        return UIColor(hue: h, saturation: 1.0, brightness: satSeed, alpha: 1.0)
    }
    
    func chooseColor() {
        while self.usedSeed.contains(self.currentSeed) {
            currentSeed++
        }
        let colorRGB = generateColor(self.currentSeed)
        self.chosenColor = colorRGB
        UIView.animateWithDuration(0.3) { () -> Void in
            self.backView.backgroundColor = self.chosenColor
        }
    }
    
    @IBAction func generateColorTouch(sender: AnyObject) {
        self.currentSeed++
        self.chooseColor()
    }
}
