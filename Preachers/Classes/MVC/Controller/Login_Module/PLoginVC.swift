//
//  PLoginVC.swift
//  Preachers
//
//  Created by Abel Anca on 9/18/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import Parse
import KVNProgress
import ReachabilitySwift

class PLoginVC: UIViewController, UITextFieldDelegate {

    //@IBOutlet weak private var viewNoNetworkConnection: UIView!
    //@IBOutlet weak var constXOriginNoNetworkView: NSLayoutConstraint!
    
    // IBOutlet
    
    @IBOutlet var txfUsername: UITextField!
    @IBOutlet var txfPassword: UITextField!
    
    @IBOutlet var btnGo: UIButton!
    @IBOutlet var btnSignUp: UIButton!
    @IBOutlet var btnLogin: UIButton!

    let blueColor                  = UIColor(red: 89 / 255.0, green: 192 / 255.0, blue: 251 / 255.0, alpha: 1)
    let whiteColor                 = UIColor.whiteColor()
    
    var isLoginSelected            = false
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txfUsername.text = "Abel Anca"
        txfPassword.text = "qwerty"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged_Notification:", name: ReachabilityChangedNotification, object: appDelegate.reachability)

        setupUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        // Initial reachability check
//        if let reachability = appDelegate.reachability {
//            if reachability.isReachable() {
//                hideNoInternetConnectionView()
//            }
//            else {
//                showNoInternetConnectionView()
//            }
//        }
    }
    
//    // MARK: - Notification Methods
//    
//    func reachabilityChanged_Notification(notification: NSNotification) {
//        if let reachability = notification.object as? Reachability {
//            if reachability.isReachable() {
//                hideNoInternetConnectionView()
//            }
//            else {
//                showNoInternetConnectionView()
//            }
//        }
//    }

    
    // MARK: - Custom Methods
    func setupUI() {
        txfUsername.layer.cornerRadius    = 15.0
        txfUsername.layer.masksToBounds   = true
        txfUsername.layer.borderColor     = UIColor.whiteColor().CGColor
        txfUsername.layer.borderWidth     = 1.0
        
        txfPassword.layer.cornerRadius    = 15.0
        txfPassword.layer.masksToBounds   = true
        txfPassword.layer.borderColor     = UIColor.whiteColor().CGColor
        txfPassword.layer.borderWidth     = 1.0
        
        btnGo.layer.cornerRadius          = 15.0
        btnGo.layer.masksToBounds         = true
        btnGo.layer.borderColor           = UIColor.whiteColor().CGColor
        btnGo.layer.borderWidth           = 1.0 
    }
    
    func pushNextVC() {
        let setProfileVC                  = appDelegate.storyboardLogin.instantiateViewControllerWithIdentifier("PSetProfileVC") as! PSetProfileVC

        setProfileVC.username             = txfUsername.text!
        setProfileVC.password             = txfPassword.text!

        self.navigationController?.pushViewController(setProfileVC, animated: true)
    }
    
    func checkUsernameAndPassIsValid() -> Bool {
        if let countUsername = txfUsername.text?.utf16.count {
            if let countPassword = txfPassword.text?.utf16.count {
                if countUsername >= 6 && countPassword >= 6 {
                    return true
                }
                else {
                    return false
                }
            }
        }
        return false
    }
    
    func selectSignUp() {
        btnSignUp.selected      = true
        btnSignUp.setTitleColor(blueColor, forState: .Normal)
        
        btnLogin.selected       = false
        btnLogin.setTitleColor(whiteColor, forState: .Normal)
        
        isLoginSelected         = false
    }
    
    func selectLogin() {
        btnSignUp.selected      = false
        btnSignUp.setTitleColor(whiteColor, forState: .Normal)
        
        btnLogin.selected       = true
        btnLogin.setTitleColor(blueColor, forState: .Normal)
        
        isLoginSelected         = true
    }
    
//    func hideNoInternetConnectionView() {
//        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
//            self.constXOriginNoNetworkView.constant = -20
//            self.viewNoNetworkConnection.alpha = 0
//            //self.viewNoNetworkConnection.hidden = true
//            self.view.layoutIfNeeded()
//            }) { (finished) -> Void in
//                
//        }
//    }
//    
//    func showNoInternetConnectionView() {
//        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
//            self.constXOriginNoNetworkView.constant = 20
//            self.viewNoNetworkConnection.alpha = 1
//            //self.viewNoNetworkConnection.hidden = false
//            
//            self.view.layoutIfNeeded()
//            }) { (finished) -> Void in
//                
//        }
//    }
    
    // MARK: - API Methods
    
    func signUp_APICall() {
        let user = PFUser()
        user.username               = txfUsername.text
        user.password               = txfPassword.text
        
        KVNProgress.showWithStatus("Waiting...")
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                KVNProgress.dismiss()
                let errorString = error.userInfo["error"] as! String
                let alert = Utils.okAlert("Error", message: errorString)
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                self.pushNextVC()
                KVNProgress.dismiss()
            }
        }
    }
    
    func login_APICall() {
        KVNProgress.showWithStatus("Waiting...")
        PFUser.logInWithUsernameInBackground(txfUsername.text!, password:txfPassword.text!) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                if user?["emailVerified"] as? Bool == true {
                    appDelegate.curUserID     = user?.objectId
                    
                    //>     Save user's ID locally, to know which user is logged in
                    appDelegate.defaults.setObject(appDelegate.curUserID, forKey: k_UserDef_LoggedInUserID)
                    appDelegate.defaults.synchronize()
                    
                    self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                    KVNProgress.dismiss()
                }
                else {
                    if user?.email == nil {
                        KVNProgress.dismiss()
                        self.pushNextVC()
                    }
                    else {
                        KVNProgress.dismiss()
                        let alert = UIAlertController(title: "Email adress verification!", message: "We have sent you an email that contains a link - you must click this link before you can continue.", preferredStyle:.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            } else {
                KVNProgress.dismiss()
                if let error = error {
                    let errorString            = error.userInfo["error"] as! String
                    let alert                  = Utils.okAlert("Error", message: errorString)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
        KVNProgress.dismiss()
    }
    
    func browseAnonymously_APICall() {
        KVNProgress.showWithStatus("Waiting...")
        PFAnonymousUtils.logInWithBlock {
            (user: PFUser?, error: NSError?) -> Void in
            if error != nil || user == nil {
                print("Anonymous login failed.")
                KVNProgress.dismiss()
            } else {
                print("Anonymous user logged in.")
                appDelegate.curUserID     = k_UserAnonymous
                
                //>     Save user's ID locally, to know which user is logged in
                appDelegate.defaults.setObject(appDelegate.curUserID, forKey: k_UserDef_LoggedInUserID)
                appDelegate.defaults.synchronize()

                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                KVNProgress.dismiss()
            }
            KVNProgress.dismiss()
        }
    }
    
    // MARK: - Action Methods
    
    @IBAction func btnGo_Action() {
        if checkUsernameAndPassIsValid() == true {
            if isLoginSelected == false {
                signUp_APICall()
            }
            else {
                login_APICall()
            }
        }
        else {
            let alert = Utils.okAlert("Oops!", message: "Username and password should be at least 6 characters.")
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnForgotPass_Action(sender: AnyObject) {
        let forgotPassVC = appDelegate.storyboardLogin.instantiateViewControllerWithIdentifier("PForgotPassVC") as! PForgotPassVC
        self.navigationController?.pushViewController(forgotPassVC, animated: true)
    }
    
    @IBAction func btnSignUp_Action(sender: AnyObject) {
        selectSignUp()
    }

    @IBAction func btnLogin_Action(sender: AnyObject) {
        selectLogin()
    }
    
    
    @IBAction func btnBrowseAnonymously_Action(sender: AnyObject) {
        browseAnonymously_APICall()
    }
    
    // MARK: - UITextFieldDelegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == txfUsername {
            txfPassword.becomeFirstResponder()
        }
        else
            if textField == txfPassword {
                txfPassword.resignFirstResponder()
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
