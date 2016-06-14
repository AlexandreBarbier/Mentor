//
//  ColorGenerationViewController.swift
//  Mentor
//
//  Created by Alexandre barbier on 11/01/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class ColorGenerationViewController: UIViewController {
    
    @IBOutlet var backView: UIView!
    @IBOutlet var generateColorTouch: UIButton!
    @IBOutlet var chooseColorButton: UIButton!
    
    var chosenColor : UIColor!
    var teamName : String = ""
    var completion : ((team:Team,color:UIColor, colorSeed:CGFloat) -> Void)?
    var canChoose = false
    
    var team : Team! {
        didSet {
            ColorGenerator.CGSharedInstance.team = team
        }
    }
}

// MARK: - View lifecycle
extension ColorGenerationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        ColorGenerator.CGSharedInstance.readyBlock = { (ready:Bool) in
            self.chooseColor()
        }
        generateColorTouch = {
            $0.rounded(5.0)
            $0.backgroundColor = UIColor.clearColor()
            return $0
        }(generateColorTouch)       
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if team == nil {
            ColorGenerator.CGSharedInstance.currentSeed = 0.0
            chooseColor()
        }
        if !canChoose {
            chooseColorButton.hidden = true
        }
    }
}

// MARK: - Helpers
extension ColorGenerationViewController {
    func chooseColor() {
        
        let colorRGB = ColorGenerator.CGSharedInstance.getNextColor()!.color
        chosenColor = colorRGB
        UIView.animateWithDuration(0.3) { () -> Void in
            self.backView.backgroundColor = self.chosenColor
        }
    }
}

// MARK: - Actions
extension ColorGenerationViewController {
    @IBAction func chooseColorTouch(sender: AnyObject) {
        completion?(team: team, color: chosenColor, colorSeed: ColorGenerator.CGSharedInstance.currentSeed)
    }
    
    @IBAction func generateColorTouch(sender: AnyObject) {
        chooseColor()
    }
}
