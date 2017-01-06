//
//  UIColor.swift
//  Preachers
//
//  Created by Abel Anca on 10/15/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit

extension UIColor {
    class func color(_ red: Double, green: Double, blue: Double, alpha: Double) -> UIColor {
        return UIColor(red: CGFloat(red / 255.0), green: CGFloat(green / 255.0), blue: CGFloat(blue / 255.0), alpha: CGFloat(alpha))
    }
    
    class func preachersBlue() -> UIColor {
        return UIColor.color(51, green: 161, blue: 228, alpha: 1)
    }
    
    class func preachersGrey() -> UIColor {
        return UIColor.color(51, green: 161, blue: 228, alpha: 0.3)
    }
}
