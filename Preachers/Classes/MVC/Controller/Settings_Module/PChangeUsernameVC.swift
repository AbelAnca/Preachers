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
        btnChangeUsername.layer.borderColor      = UIColor.black.cgColor
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
        let alert = UIAlertController(title: "Important!", message: "You can't reuse your old username once you change it.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Change username", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            
            let currentUser                = PFUser.current()
            currentUser?.username          = self.txfNewUsername.text
            
            KVNProgress.show(withStatus: "Changing...")
            currentUser?.saveInBackground(block: { (success, error) -> Void in
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
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
        }))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Action Methods

    @IBAction func btnBack_Action(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSave_Action(_ sender: AnyObject) {
        if checkUsernameIfIsValid() == true {
            changeUsername_APICall()
        }
        else {
            let alert = Utils.okAlert("Oops!", message: "Username should be at least 6 characters.")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txfNewUsername {
            txfNewUsername.resignFirstResponder()
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
