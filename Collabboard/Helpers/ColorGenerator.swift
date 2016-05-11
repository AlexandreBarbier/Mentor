//
//  ColorGenerator.swift
//  Collabboard
//
//  Created by Alexandre barbier on 22/02/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class ColorGenerator {
    private struct CGeneratorConstant {
        static let maxSeed : CGFloat = 12.0
        static let saturation : CGFloat = 1.0
    }
    private var satSeed : CGFloat = 1.0
    private var usedSeed = [CGFloat]()
    
    static let CGSharedInstance = ColorGenerator()
    var currentSeed : CGFloat = -1.0
    var readyBlock : ((ready:Bool)->Void)?
    var team : Team! {
        didSet {
            currentSeed = -1.0
            team.getUsers { (users, error) -> Void in
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
    
    private init() {
        
    }
    
    func reset() {
        usedSeed.removeAll()
        currentSeed = -1
        readyBlock = nil
    }
    
    func generateColor(seed:CGFloat) -> UIColor! {
        let maxSeed = CGeneratorConstant.maxSeed
        let h = seed <= maxSeed ? (seed / maxSeed) : ((seed % maxSeed) / maxSeed)
        satSeed = seed <= maxSeed ? 1 : 1 - ((seed % maxSeed) / maxSeed)
        return UIColor(hue: h, saturation: CGeneratorConstant.saturation, brightness: satSeed, alpha: 1.0)
    }
    
    func getNextColor() -> UIColor? {
        if let _ = readyBlock {
            guard currentSeed != -1 else {
                return nil
            }
        }
        currentSeed += 1
        while usedSeed.contains(currentSeed) {
            currentSeed += 1
        }
        return generateColor(currentSeed)
    }
}
