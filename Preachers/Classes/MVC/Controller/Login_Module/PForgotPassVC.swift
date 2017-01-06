//
//  PForgotPassVC.swift
//  Preachers
//
//  Created by Abel Anca on 9/24/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import KVNProgress

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

        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Notification Methods

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
    
    // MARK: - API Methods
    
    // MARK: - Action Methods
    @IBAction func btnBack_Action(_ sender: AnyObject) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnRequest_Action() {
        let forgotPassVC = appDelegate.storyboardLogin.instantiateViewController(withIdentifier: "PConfirmForgotPassVC") as! PConfirmForgotPassVC
        self.navigationController?.pushViewController(forgotPassVC, animated: true)
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
