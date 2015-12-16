//
//  Utils.swift
//  Preachers
//
//  Created by Abel Anca on 9/19/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit

class Utils: NSObject {

    class func okAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle:.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        return alert
    }
    
    class func isValidEmail(testStr:String) -> Bool {
        let emailRegEx   = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest    = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result       = emailTest.evaluateWithObject(testStr)
        return result
    }
    
    class func noNetworkConnectioAlert() -> UIAlertController {
        let alert = UIAlertController(title: "No Internet Connection", message: "Please reestablish your Internet connection and try again.", preferredStyle:.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
        
        return alert
    }
}
