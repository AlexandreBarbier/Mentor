//
//  Counter.swift
//  Voice
//
//  Created by Alexandre barbier on 09/10/14.
//  Copyright (c) 2014 Alexandre barbier. All rights reserved.
//

import ABModel

public class Counter: ABModel {
    public var collected = -1
    public var followers = -1
    public var following = -1
    public var questions = -1
    public var reposts = -1
    public var votes = -1
    public var logins = Logins()
}

public class Logins: ABModel {
     public var all = -1
     public var mobile = -1
     public var mweb = -1
     public var web = -1
     public var widget = -1
}