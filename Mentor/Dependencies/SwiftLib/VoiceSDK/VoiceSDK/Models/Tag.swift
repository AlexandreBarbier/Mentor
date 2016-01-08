//
//  Tag.swift
//  Voice
//
//  Created by Alexandre barbier on 09/10/14.
//  Copyright (c) 2014 Alexandre barbier. All rights reserved.
//

import ABModel

public class Tag : ABModel {
    public override var description : String { get { return "id : \(self.id) name : \(self.name)"} }
    public var id = 0
    public var name = ""
}
