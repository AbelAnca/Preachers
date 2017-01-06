//
//  Church.swift
//  Preachers
//
//  Created by Abel Anca on 10/14/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import Parse

class Church : PFObject, PFSubclassing {
    
    private static var __once: () = {
            self.registerSubclass()
        }()
    
    @NSManaged var city: String
    @NSManaged var name: String?
    @NSManaged var address: String?
    @NSManaged var distance: String?
    @NSManaged var pastor: String?
    @NSManaged var note: String?
    @NSManaged var user: PFUser
    @NSManaged var image: PFFile?
    @NSManaged var place: PFGeoPoint?
    
    override class func initialize() {
        struct Static {
            static var onceToken : Int = 0;
        }
        _ = Church.__once
    }
    
    static func parseClassName() -> String {
        return "Church"
    }
}
