//
//  PAddVisitVC.swift
//  Preachers
//
//  Created by Abel Anca on 10/13/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import Parse
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class PAddVisitVC: UIViewController {

    @IBOutlet var txfBiblicalText: UITextField!
    @IBOutlet var txvMyPreach: UITextView!
    @IBOutlet var txvObservation: UITextView!
    @IBOutlet var datePiker: UIDatePicker!
    
    var currentChurch: PFObject?
    var date: String?
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setCurrentDate(Date())
    }

    // MARK: - Custom Methods
    
    func setCurrentDate(_ currentDate: Date) {
        let dateFormatter             = DateFormatter()
        dateFormatter.dateFormat      = "dd-MM-yyyy"
        date = dateFormatter.string(from: currentDate)
    }
    
    func verifyBiblicalText() -> Bool {
        if txfBiblicalText.text?.utf16.count < 3 {
            return false
        }
        else {
            return true
        }
    }
    
    // MARK: - API Methods
    
    func saveVisit_APICall() {
        if verifyBiblicalText() == true {
            let preach                    = Preach()
            preach.biblicalText           = txfBiblicalText.text
            preach.myPreach               = txvMyPreach.text
            preach.observation            = txvObservation.text
            preach.date                   = date
            preach.church                 = self.currentChurch!
            preach.saveInBackground { (success, error) -> Void in
                if error == nil {
                    if success {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                else {
                    if let error = error {
                        let errorString     = error._userInfo["error"] as! String
                        let alert           = Utils.okAlert("Error", message: errorString)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        else {
            let alert = Utils.okAlert("Upss", message: "The biblical text is required")
            present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Action Methods
    
    @IBAction func btnBack_Action(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSave_Action(_ sender: AnyObject) {
        saveVisit_APICall()
    }
    
    @IBAction func datePicker_Action(_ sender: UIDatePicker) {
        setCurrentDate(sender.date)
    }
    
    // MARK: - StatusBar Methods
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // MARK: - Memory Management Methods
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
