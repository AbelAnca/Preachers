//
//  Place.swift
//  Preachers
//
//  Created by Abel Anca on 12/18/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import MapKit
import UIKit

class Place: NSObject, MKAnnotation {
    
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    
    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
}
