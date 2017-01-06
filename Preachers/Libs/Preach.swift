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
    
    private static var __once: () = {
            self.registerSubclass()
        }()
    
    @NSManaged var biblicalText: String?
    @NSManaged var myPreach: String?
    @NSManaged var observation: String?
    @NSManaged var date: String?
    @NSManaged var church: PFObject
    
    
    override class func initialize() {
        struct Static {
            static var onceToken : Int = 0;
        }
        _ = Preach.__once
    }
    
    static func parseClassName() -> String {
        return "Preach"
    }
}
