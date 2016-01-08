//
//  Media.swift
//  Voice
//
//  Created by Alexandre barbier on 09/10/14.
//  Copyright (c) 2014 Alexandre barbier. All rights reserved.
//

import ABModel

public enum MediaType : String {
    case None = ""
    case VideoType = "video"
    case ImageType = "image"
    case EmbedType = "embed"
    case LinkType = "link"
    
    init(media:String) {
        switch media {
        case None.rawValue :
            self = MediaType.None
        case VideoType.rawValue :
            self = MediaType.VideoType
        case ImageType.rawValue :
            self = MediaType.ImageType
        case EmbedType.rawValue :
            self = MediaType.EmbedType
        case LinkType.rawValue :
            self = MediaType.LinkType
        default :
            self = MediaType.None
        }
    }
}

public class Media: ABModel {
  public override var description :String { get { return "link : \(self.link)  type: \(self.type)"} }
    public var height = 0.0
    public var width = 0.0
    public var link = ""
    public var type : String = "" {
        didSet {
            if type != mediaType.rawValue {
                mediaType = MediaType(media: type)
            }
        }
    }
    public var mediaType : MediaType = MediaType.None {
        didSet {
            if type != mediaType.rawValue {
                type = mediaType.rawValue
            }
        }
    }
    
}
