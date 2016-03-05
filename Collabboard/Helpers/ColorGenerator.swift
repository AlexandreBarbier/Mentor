//
//  ColorGenerator.swift
//  Collabboard
//
//  Created by Alexandre barbier on 22/02/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit





class ColorGenerator {
    var currentSeed : CGFloat = -1.0
    private var satSeed : CGFloat = 1.0
    private var usedSeed = [CGFloat]()

    static let CGSharedInstance = ColorGenerator()

    var readyBlock : ((ready:Bool)->Void)?
    
    private init() {
        
    }
    
    private struct CGeneratorConstant {
        static let maxSeed : CGFloat = 12.0
        static let saturation : CGFloat = 1.0
    }
    
    var team : Team! {
        didSet {
            self.currentSeed = -1.0
            self.team.getUsers { (users, error) -> Void in
                for user in users {
                    user.getTeamColor(self.team, completion: { (teamColor, utColor, error) -> Void in
                        self.usedSeed.append(utColor.colorSeed)
                        if utColor.colorSeed > self.currentSeed {
                            self.currentSeed = utColor.colorSeed
                        }
                        if self.usedSeed.count == self.team.users.count {
                            self.readyBlock?(ready:true)
                        }
                    })
                }
            }
        }
    }
    
    func generateColor(seed:CGFloat) -> UIColor! {
        let h = seed <= CGeneratorConstant.maxSeed ? (seed / CGeneratorConstant.maxSeed) : ((seed % CGeneratorConstant.maxSeed) / CGeneratorConstant.maxSeed)
        satSeed = seed <= CGeneratorConstant.maxSeed ? 1 : 1 - ((seed % CGeneratorConstant.maxSeed) / CGeneratorConstant.maxSeed)
        return UIColor(hue: h, saturation: CGeneratorConstant.saturation, brightness: satSeed, alpha: 1.0)
    }

    func getNextColor() -> UIColor? {
        if let _ = readyBlock {
            guard self.currentSeed != -1 else {
                return nil
            }
        }
        currentSeed++
        while self.usedSeed.contains(self.currentSeed) {
            currentSeed++
        }
        return generateColor(self.currentSeed)
    }
}
