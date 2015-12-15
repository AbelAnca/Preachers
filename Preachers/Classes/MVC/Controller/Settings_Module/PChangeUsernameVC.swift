//
//  PChangeUsernameVC.swift
//  Preachers
//
//  Created by Abel Anca on 9/29/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import Parse
import KVNProgress

class PChangeUsernameVC: UIViewController, UITextFieldDelegate {

    @IBOutlet var txfNewUsername: UITextField!
    @IBOutlet var btnChangeUsername: UIButton!
    
    // MARK: ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Custom Methods
    
    func setupUI() {
        btnChangeUsername.layer.cornerRadius     = 8
        btnChangeUsername.layer.borderWidth      = 0.5
        btnChangeUsername.layer.borderColor      = UIColor.blackColor().CGColor
        btnChangeUsername.clipsToBounds          = true
    }
    
    func checkUsernameIfIsValid() -> Bool {
        if txfNewUsername != nil {
            if let countUsername = txfNewUsername.text?.utf16.count {
                if countUsername >= 6 {
                    return true
                }
                else {
                    return false
                }
            }
        }
        return false
    }
    
    // MARK: - API Methods
    
    func changeUsername_APICall() {
        let alert = UIAlertController(title: "Important!", message: "You can't reuse your old username once you change it.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Change username", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            let currentUser                = PFUser.currentUser()
            currentUser?.username          = self.txfNewUsername.text
            
            KVNProgress.showWithStatus("Changing...")
            currentUser?.saveInBackgroundWithBlock({ (success, error) -> Void in
                if error == nil {
                    if success {
                        KVNProgress.dismiss()
                    }
                }
                else {
                    if let error = error {
                        KVNProgress.dismiss()
                        let errorString     = error.userInfo["error"] as! String
                        let alert           = Utils.okAlert("Error", message: errorString)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - Action Methods

    @IBAction func btnBack_Action(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnSave_Action(sender: AnyObject) {
        if checkUsernameIfIsValid() == true {
            changeUsername_APICall()
        }
        else {
            let alert = Utils.okAlert("Oops!", message: "Username should be at least 6 characters.")
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - UITextFieldDelegate Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == txfNewUsername {
            txfNewUsername.resignFirstResponder()
        }
        return false
    }
    
    // MARK: - StatusBar Methods
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: - MemoryManagement Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
