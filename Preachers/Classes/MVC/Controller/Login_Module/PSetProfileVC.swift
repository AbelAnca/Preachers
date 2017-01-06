//
//  PSetProfileVC.swift
//  Preachers
//
//  Created by Abel Anca on 9/18/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import KVNProgress

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
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - Notification Methods
    
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

    // MARK: - API Methods
    
    // MARK: - Action Methods

    @IBAction func btnStart_Action(_ sender: AnyObject) {
        self.navigationController?.dismiss(animated: true, completion: nil)
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
