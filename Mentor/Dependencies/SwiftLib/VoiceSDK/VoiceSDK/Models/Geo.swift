//
//  Geo.swift
//  Voice
//
//  Created by Alexandre barbier on 09/10/14.
//  Copyright (c) 2014 Alexandre barbier. All rights reserved.
//

import ABModel

public class Geo: ABModel {
  public override var description : String { get { return "country : \(self.country)"} }
    public var country = ""
    public var region = ""
    public var city = ""
    public var ll  = [Float?]()
}
