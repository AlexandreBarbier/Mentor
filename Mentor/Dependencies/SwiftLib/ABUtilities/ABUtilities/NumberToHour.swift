//
//  NumberToHour.swift
//  Rate Me
//
//  Created by Alexandre barbier on 20/09/14.
//  Copyright (c) 2014 abarbier. All rights reserved.
//

import Foundation

func measure(title: String!, call: () -> Void) {
    let startTime = CACurrentMediaTime()
    call()
    let endTime = CACurrentMediaTime()
    if let title = title {
        print("\(title): ")
    }
    println("Time - \(endTime - startTime)")
}

public extension Int {
    public func toHourString(withSemiColon:Bool) -> String! {
        var semiCol = ""
        if withSemiColon {
            semiCol = ":"
        }
        switch self {
        case 0...9 :
            return "0\(self)" + semiCol
            
        default :
            return "\(self)" + semiCol
        }
    }
    
}

public extension Double {
    
    public func toHourString(withSemiColon:Bool) -> String {
        var h = self / 3600
        var m = (self / 60) % 60
        var s = self % 60
        return "\(Int(h).toHourString(true))\(Int(m).toHourString(true))\(Int(s).toHourString(false))"
    }
}

public extension Float {
    
    public func toHourString(withSemiColon:Bool) -> String {
        var h = self / 3600
        var m = (self / 60) % 60
        var s = self % 60
        return "\(Int(h).toHourString(true))\(Int(m).toHourString(true))\(Int(s).toHourString(false))"
    }
    
}
