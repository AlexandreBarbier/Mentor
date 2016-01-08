//
//  Choice.swift
//  Voice
//
//  Created by Alexandre barbier on 09/10/14.
//  Copyright (c) 2014 Alexandre barbier. All rights reserved.
//

import ABModel

public class Choice: ABModel {
    public override var description : String { get { return "Choice = \(self.choice) : \(self.votes), min : \(self.min), max : \(self.max)"} }
    public var choice = NSString()
    public var votes = 0
    public var iqr_min : Float = 0.0
    public var iqr_max : Float = 0.0
    public var std_dev : Float = 0.0
    public var pre_s : Float = 0.0
    public var pre_sd : Float = 0.0
    public var max : Float = 0.0
    public var min : Float = 0.0
    public var scale : Float = 0.0
    public var average : Float = 0.0
    public var accuracy : Float = 0.0
    public var unit : String = ""
}
