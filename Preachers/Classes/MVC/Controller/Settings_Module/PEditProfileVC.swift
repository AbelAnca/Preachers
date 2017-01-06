//
//  PEditProfileVC.swift
//  Preachers
//
//  Created by Abel Anca on 9/29/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
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
    
    func setBirthdateFromDatePicker(_ date: Date) {
        let dateFormatter            = DateFormatter()
        dateFormatter.dateFormat     = "dd-MM-yyyy"
        strBirthdate                 = dateFormatter.string(from: date)
    }
    
    // MARK: - API Methods
    
    func loadParams_APICall() {
    }
    
    func saveParams_APICall() {
    }

    // MARK: - Action Methods

    @IBAction func btnBack_Action(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func btnSave_Action(_ sender: AnyObject) {
        saveParams_APICall()
    }
    
    @IBAction func datePicker_Action(_ sender: UIDatePicker) {
        setBirthdateFromDatePicker(sender.date)
    }
    
    // MARK: - UITextFieldDelegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
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
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
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
