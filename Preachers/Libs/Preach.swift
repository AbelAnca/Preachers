//
//  Preach.swift
//  Preachers
//
//  Created by Abel Anca on 10/14/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import Parse

class Preach : PFObject, PFSubclassing {
    
    @NSManaged var biblicalText: String?
    @NSManaged var myPreach: String?
    @NSManaged var observation: String?
    @NSManaged var date: String?
    @NSManaged var church: PFObject
    
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Preach"
    }
}
