//
//  PEditProfileVC.swift
//  Preachers
//
//  Created by Abel Anca on 9/29/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import Parse
import KVNProgress

class PEditProfileVC: UIViewController, UITextFieldDelegate {

    @IBOutlet var txfEmail: UITextField!
    @IBOutlet var txfFirstName: UITextField!
    @IBOutlet var txfLastName: UITextField!
    @IBOutlet var txfPhone: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    
    var strBirthdate: String?
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        loadParams_APICall()
    }
    
    // MARK: - Custom Methods
    func verifyEmail() -> Bool {
        if txfEmail.text != nil {
            if let email = txfEmail.text {
                return Utils.isValidEmail(email)
            }
        }
        return false
    }
    
    func setBirthdateFromDatePicker(date: NSDate) {
        let dateFormatter            = NSDateFormatter()
        dateFormatter.dateFormat     = "dd-MM-yyyy"
        strBirthdate                 = dateFormatter.stringFromDate(date)
    }
    
    // MARK: - API Methods
    
    func loadParams_APICall() {
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            
            if let email = currentUser?.email {
                txfEmail.text = "\(email)"
            }
            
            if let firstname = currentUser?["firstname"] {
                txfFirstName.text = "\(firstname)"
            }
            
            if let lastname = currentUser?["lastname"] {
                txfLastName.text = "\(lastname)"
            }
            
            if let phone = currentUser?["phone"] {
                txfPhone.text = "\(phone)"
            }
            
            if let birthdate = currentUser?["birthdate"] as? String {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"
                
                if let date = dateFormatter.dateFromString(birthdate) {
                    datePicker.date = date
                }
                strBirthdate = birthdate
            }
        }
    }
    
    func saveParams_APICall() {
        let user = PFUser.currentUser()
        if user != nil {
            user?.setValue(self.txfPhone.text, forKey: "phone")
            user?.setValue(self.strBirthdate, forKey: "birthdate")
            user?.setValue(self.txfFirstName.text, forKey: "firstname")
            user?.setValue(self.txfLastName.text, forKey: "lastname")
            KVNProgress.showWithStatus("Saving...")
            user?.saveInBackgroundWithBlock({ (success, error) -> Void in
                if error == nil {
                    if success {
                        self.dismissViewControllerAnimated(true, completion: nil)
                        KVNProgress.dismiss()
                    }
                }
                else {
                    if let error = error {
                        KVNProgress.dismiss()
                        let errorString        = error.userInfo["error"] as! String
                        let alert              = Utils.okAlert("Error", message: errorString)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            })
        }
    }

    // MARK: - Action Methods

    @IBAction func btnBack_Action(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func btnSave_Action(sender: AnyObject) {
        saveParams_APICall()
    }
    
    @IBAction func datePicker_Action(sender: UIDatePicker) {
        setBirthdateFromDatePicker(sender.date)
    }
    
    // MARK: - UITextFieldDelegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == txfEmail {
            txfFirstName.becomeFirstResponder()
        }
        else
            if textField == txfFirstName {
                txfLastName.becomeFirstResponder()
            }
            else
                if textField == txfLastName {
                    txfPhone.becomeFirstResponder()
                    
                }
                else if textField == txfPhone {
                    txfPhone.resignFirstResponder()
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
