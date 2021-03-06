//
//  ColorGenerator.swift
//  Collabboard
//
//  Created by Alexandre barbier on 22/02/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class ColorGenerator {
    static let instance = ColorGenerator()

    fileprivate struct CGeneratorConstant {
        static let maxSeed: CGFloat = 11.0
        static let saturation: CGFloat = 1.0
    }
    fileprivate var satSeed: CGFloat = 1.0
    fileprivate var usedSeed = [CGFloat]()

    var currentSeed: CGFloat = -1.0
    var readyBlock: ((_ ready: Bool) -> Void)?
    var team: Team! {
        didSet {
            currentSeed = -1.0
            team.getUsers { (users, error) -> Void in
                for user in users {
                    user.getTeamColors(self.team, completion: { (_, utColor, error) -> Void in
                        guard let utColor = utColor, error == nil else {
                            return
                        }
                        self.usedSeed.append(utColor.colorSeed)
                        if utColor.colorSeed > self.currentSeed {
                            self.currentSeed = utColor.colorSeed
                        }
                        if self.usedSeed.count == self.team.users.count {
                            self.readyBlock?(true)
                        }
                    })
                }
            }
        }
    }

    fileprivate init() {

    }

    func reset() {
        usedSeed.removeAll()
        currentSeed = -1
        readyBlock = nil
    }

    func generateColor(_ seed: CGFloat) -> UIColor! {
        let maxSeed = CGeneratorConstant.maxSeed
        let h = seed <= maxSeed ? (seed / maxSeed) : ((seed.truncatingRemainder(dividingBy: maxSeed)) / maxSeed)
        satSeed = seed <= maxSeed ? 1 : 1 - ((seed.truncatingRemainder(dividingBy: maxSeed)) / maxSeed)
        return UIColor(hue: h, saturation: CGeneratorConstant.saturation, brightness: satSeed, alpha: 1.0)
    }

    func getNextColor() -> (color: UIColor, colorSeed: CGFloat)? {
        if let _ = readyBlock {
            guard currentSeed != -1 else {
                return nil
            }
        }
        currentSeed += 1
        while usedSeed.contains(currentSeed) {
            currentSeed += 1
        }
        return (generateColor(currentSeed), currentSeed)
    }
}
