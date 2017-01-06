//
//  PSetProfileVC.swift
//  Preachers
//
//  Created by Abel Anca on 9/18/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import Parse
import KVNProgress
import ReachabilitySwift

class PSetProfileVC: UIViewController, UITextFieldDelegate {

    @IBOutlet var btnStart: UIButton!
    
    @IBOutlet var txfEmail: UITextField!
    @IBOutlet var txfPhone: UITextField!
    @IBOutlet var txfFirstName: UITextField!
    @IBOutlet var txfLastName: UITextField!
    
    @IBOutlet weak fileprivate var viewNoNetworkConnection: UIView!
    @IBOutlet weak var constXOriginNoNetworkView: NSLayoutConstraint!
    
    var birthdate: String?
    var username:  String?
    var password:  String?
    
    var isFirst    = true

    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txfEmail.text = "abel.anca95@gmail.com"
        txfPhone.text = "0754823095"
        birthdate = "26.09.1995"
        txfFirstName.text = "Anca"
        txfLastName.text = "Abel"
        
        NotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged_Notification:", name: ReachabilityChangedNotification, object: appDelegate.reachability)
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Initial reachability check
        if let reachability = appDelegate.reachability {
            if reachability.isReachable() {
                hideNoInternetConnectionView()
            }
            else {
                showNoInternetConnectionView()
            }
        }
    }
    
    // MARK: - Notification Methods
    
    func reachabilityChanged_Notification(_ notification: Notification) {
        if let reachability = notification.object as? Reachability {
            if reachability.isReachable() {
                hideNoInternetConnectionView()
            }
            else {
                showNoInternetConnectionView()
            }
        }
    }
    
    // MARK: - Custom Methods
    func setupUI() {
        btnStart.layer.cornerRadius          = 15.0
        btnStart.layer.masksToBounds         = true
        btnStart.layer.borderColor           = UIColor.white.cgColor
        btnStart.layer.borderWidth           = 1.0
        
        setDateForBirthdate(Date())
    }
    
    func verifyEmail() -> Bool {
        if txfEmail.text != nil {
            if let email = txfEmail.text {
                return Utils.isValidEmail(email)
            }
        }
        return false
    }
    
    func setDateForBirthdate(_ date: Date) {
        let dateFormatter            = DateFormatter()
        dateFormatter.dateFormat     = "dd-MM-yyyy"
        birthdate                    = dateFormatter.string(from: date)
    }
    
    func hideNoInternetConnectionView() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            self.constXOriginNoNetworkView.constant = -50
            self.viewNoNetworkConnection.alpha = 0
            //self.viewNoNetworkConnection.hidden = true
            self.view.layoutIfNeeded()
            }) { (finished) -> Void in
                
        }
    }
    
    func showNoInternetConnectionView() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            self.constXOriginNoNetworkView.constant = 0
            self.viewNoNetworkConnection.alpha = 1
            //self.viewNoNetworkConnection.hidden = false
            
            self.view.layoutIfNeeded()
            }) { (finished) -> Void in
                
        }
    }

    // MARK: - API Methods

    func login_APICall() {
        if let username = username {
            if let password = password {
                if verifyEmail() == true {
                    KVNProgress.show(withStatus: "Waiting...")
                    PFUser.logInWithUsername(inBackground: username, password:password) {
                        (user: PFUser?, error: NSError?) -> Void in
                        if user != nil {
                            if user?["emailVerified"] as? Bool == true {
                                appDelegate.curUserID     = user?.objectId
                                
                                //>     Save user's ID locally, to know which user is logged in
                                appDelegate.defaults.set(appDelegate.curUserID, forKey: k_UserDef_LoggedInUserID)
                                appDelegate.defaults.synchronize()
                                
                                self.navigationController?.dismiss(animated: true, completion: nil)
                                KVNProgress.dismiss()
                            }
                            
                            user?.email         = self.txfEmail.text
                            user?.setValue(self.txfPhone.text, forKey: "phone")
                            user?.setValue(self.birthdate, forKey: "birthdate")
                            user?.setValue(self.txfFirstName.text, forKey: "firstname")
                            user?.setValue(self.txfLastName.text, forKey: "lastname")
                            user?.saveInBackground(block: { (success, error) -> Void in
                                if error == nil {
                                    if success {
                                        KVNProgress.dismiss()
                                        let alert = UIAlertController(title: "Email adress verification!", message: "We have sent you an email that contains a link - you must click this link before you can continue.", preferredStyle:.alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
                                        }))
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                }
                                else
                                    if let error = error {
                                        KVNProgress.dismiss()
                                        let errorString = error.userInfo["error"] as! String
                                        
                                        let alert = Utils.okAlert("Error", message: errorString)
                                        self.present(alert, animated: true, completion: nil)
                                }
                            })
                        }
                        else {
                            KVNProgress.dismiss()
                            if let error = error {
                                let errorString = error.userInfo["error"] as! String
                                
                                let alert = Utils.okAlert("Error", message: errorString)
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
                else {
                    let alert = Utils.okAlert("Email is not valid", message: "Please introduce a correct email address")
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Action Methods

    @IBAction func btnStart_Action(_ sender: AnyObject) {
        // Check internet connection
        if appDelegate.bIsNetworkReachable == false {
            let alertView = Utils.noNetworkConnectioAlert()
            self.present(alertView, animated: true, completion: nil)
            
            return
        }
        
        login_APICall()
    }
    
    @IBAction func datePicker_Action(_ sender: UIDatePicker) {
        setDateForBirthdate(sender.date)
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
