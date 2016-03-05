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
    var teamName : String = ""
    var completion : ((team:Team,color:UIColor, colorSeed:CGFloat) -> Void)?
    var canChoose = false
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var generateColorTouch: UIButton!
    @IBOutlet weak var chooseColorButton: UIButton!
    
    var team : Team! {
        didSet {
          
            ColorGenerator.CGSharedInstance.team = team
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ColorGenerator.CGSharedInstance.readyBlock = { (ready:Bool) in
            self.chooseColor()
        }
        self.generateColorTouch.rounded(5.0)
        self.generateColorTouch.backgroundColor = UIColor.clearColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if team == nil {
            ColorGenerator.CGSharedInstance.currentSeed = 0.0
            self.chooseColor()
        }
        if !canChoose {
            self.chooseColorButton.hidden = true
        }
    }
    
  
    @IBAction func chooseColorTouch(sender: AnyObject) {
        self.completion?(team: self.team,color:self.chosenColor, colorSeed:ColorGenerator.CGSharedInstance.currentSeed)
    }
    
    func chooseColor() {
        let colorRGB = ColorGenerator.CGSharedInstance.getNextColor()
        self.chosenColor = colorRGB
        UIView.animateWithDuration(0.3) { () -> Void in
            self.backView.backgroundColor = self.chosenColor
        }
    }
    
    @IBAction func generateColorTouch(sender: AnyObject) {
        self.chooseColor()
    }
}
