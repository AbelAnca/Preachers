//
//  PForgotPassVC.swift
//  Preachers
//
//  Created by Abel Anca on 9/24/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import Parse
import KVNProgress
import ReachabilitySwift

class PForgotPassVC: UIViewController, UITextFieldDelegate {

    @IBOutlet var btnRequest: UIButton!
    @IBOutlet var txfEmail: UITextField!
    
    @IBOutlet weak fileprivate var viewNoNetworkConnection: UIView!
    @IBOutlet weak var constXOriginNoNetworkView: NSLayoutConstraint!
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        txfEmail.text = "abel.anca95@gmail.com"
        
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
        btnRequest.layer.cornerRadius          = 15.0
        btnRequest.layer.masksToBounds         = true
        btnRequest.layer.borderColor           = UIColor.white.cgColor
        btnRequest.layer.borderWidth           = 1.0
    }
    
    func verifyEmail() -> Bool {
        if txfEmail.text != nil {
            if let email = txfEmail.text {
                return Utils.isValidEmail(email)
            }
        }
        return false
    }
    
    func hideNoInternetConnectionView() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            self.constXOriginNoNetworkView.constant = -40
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
    
    func requestUsername_APICall() {
        if verifyEmail() == true {
            if let email = txfEmail.text {
                KVNProgress.show(withStatus: "Waiting...")
                PFUser.requestPasswordResetForEmail(inBackground: email, block: { (success, error) -> Void in
                    if success == true {
                        let forgotPassVC = appDelegate.storyboardLogin.instantiateViewController(withIdentifier: "PConfirmForgotPassVC") as! PConfirmForgotPassVC
                        self.navigationController?.pushViewController(forgotPassVC, animated: true)
                        KVNProgress.dismiss()
                    }
                    else {
                        if let err = error {
                            KVNProgress.dismiss()
                            let alert = Utils.okAlert("Error", message: err.localizedDescription)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                })
            }
        }
        else {
            let alert = Utils.okAlert("Email is not valid", message: "Please introduce a correct email address")
            self.present(alert, animated: true, completion: nil)
        }
    }

    
    // MARK: - Action Methods
    @IBAction func btnBack_Action(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnRequest_Action() {
        // Check internet connection
        if appDelegate.bIsNetworkReachable == false {
            let alertView = Utils.noNetworkConnectioAlert()
            self.present(alertView, animated: true, completion: nil)
            
            return
        }
        
        requestUsername_APICall()
    }
    
    // MARK: - UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txfEmail {
            txfEmail.resignFirstResponder()
            btnRequest_Action()
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
