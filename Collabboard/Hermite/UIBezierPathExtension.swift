//
//  UIBezierPathExtension.swift
//  SmoothScribble
//
//  Created by Simon Gladman on 04/11/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

extension UIBezierPath {
    func interpolatePointsWithHermite(_ interpolationPoints: [CGPoint]) {
        let n = interpolationPoints.count - 1

        for ii in 0 ..< n {
            var currentPoint = interpolationPoints[ii]

            if ii == 0 {
                self.move(to: interpolationPoints[0])
            }
            var nextii = (ii + 1) % (n + 1)
            var previi = (ii - 1 < 0 ? n : ii-1)
            var previousPoint = interpolationPoints[previi]
            var nextPoint = interpolationPoints[nextii]
            let endPoint = nextPoint
            var mx: CGFloat = 0.0
            var my: CGFloat = 0.0

            mx = ii > 0 ?
                (nextPoint.x - currentPoint.x) * 0.5 + (currentPoint.x - previousPoint.x) * 0.5
                : (nextPoint.x - currentPoint.x) * 0.5
            my = ii > 0 ?
                (nextPoint.y - currentPoint.y) * 0.5 + (currentPoint.y - previousPoint.y) * 0.5
                : (nextPoint.y - currentPoint.y) * 0.5
            let controlPoint1 = CGPoint(x: currentPoint.x + mx / 3.0, y: currentPoint.y + my / 3.0)

            currentPoint = interpolationPoints[nextii]
            nextii = (nextii + 1) % (n + 1)
            previi = ii
            previousPoint = interpolationPoints[previi]
            nextPoint = interpolationPoints[nextii]

            mx = ii < n - 1 ?
                (nextPoint.x - currentPoint.x) * 0.5 + (currentPoint.x - previousPoint.x) * 0.5
                : (currentPoint.x - previousPoint.x) * 0.5
            my = ii < n - 1 ?
                (nextPoint.y - currentPoint.y) * 0.5 + (currentPoint.y - previousPoint.y) * 0.5
                : (currentPoint.y - previousPoint.y) * 0.5

            let controlPoint2 = CGPoint(x: currentPoint.x - mx / 3.0, y: currentPoint.y - my / 3.0)
            self.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        }
    }
}
