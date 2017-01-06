//
//  PLoginVC.swift
//  Preachers
//
//  Created by Abel Anca on 9/18/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import KVNProgress

class PLoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak fileprivate var viewNoNetworkConnection: UIView!
    @IBOutlet weak var constXOriginNoNetworkView: NSLayoutConstraint!
    
    // IBOutlet
    
    @IBOutlet var txfUsername: UITextField!
    @IBOutlet var txfPassword: UITextField!
    
    @IBOutlet var btnGo: UIButton!
    @IBOutlet var btnSignUp: UIButton!
    @IBOutlet var btnLogin: UIButton!

    let blueColor                  = UIColor(red: 89 / 255.0, green: 192 / 255.0, blue: 251 / 255.0, alpha: 1)
    let whiteColor                 = UIColor.white
    
    var isLoginSelected            = false
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txfUsername.text = "Abel Anca"
        txfPassword.text = "qwerty"

        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - Notification Methods
    
    // MARK: - Custom Methods
    func setupUI() {
        txfUsername.layer.cornerRadius    = 15.0
        txfUsername.layer.masksToBounds   = true
        txfUsername.layer.borderColor     = UIColor.white.cgColor
        txfUsername.layer.borderWidth     = 1.0
        
        txfPassword.layer.cornerRadius    = 15.0
        txfPassword.layer.masksToBounds   = true
        txfPassword.layer.borderColor     = UIColor.white.cgColor
        txfPassword.layer.borderWidth     = 1.0
        
        btnGo.layer.cornerRadius          = 15.0
        btnGo.layer.masksToBounds         = true
        btnGo.layer.borderColor           = UIColor.white.cgColor
        btnGo.layer.borderWidth           = 1.0 
    }
    
    func pushNextVC() {
        let setProfileVC                  = appDelegate.storyboardLogin.instantiateViewController(withIdentifier: "PSetProfileVC") as! PSetProfileVC

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
        btnSignUp.isSelected      = true
        btnSignUp.setTitleColor(blueColor, for: UIControlState())
        
        btnLogin.isSelected       = false
        btnLogin.setTitleColor(whiteColor, for: UIControlState())
        
        isLoginSelected         = false
    }
    
    func selectLogin() {
        btnSignUp.isSelected      = false
        btnSignUp.setTitleColor(whiteColor, for: UIControlState())
        
        btnLogin.isSelected       = true
        btnLogin.setTitleColor(blueColor, for: UIControlState())
        
        isLoginSelected         = true
    }
    
    // MARK: - API Methods
    
    // MARK: - Action Methods
    
    @IBAction func btnGo_Action() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnForgotPass_Action(_ sender: AnyObject) {
        let forgotPassVC = appDelegate.storyboardLogin.instantiateViewController(withIdentifier: "PForgotPassVC") as! PForgotPassVC
        self.navigationController?.pushViewController(forgotPassVC, animated: true)
    }
    
    @IBAction func btnSignUp_Action(_ sender: AnyObject) {
        selectSignUp()
    }

    @IBAction func btnLogin_Action(_ sender: AnyObject) {
        selectLogin()
    }
    
    // MARK: - UITextFieldDelegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
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
