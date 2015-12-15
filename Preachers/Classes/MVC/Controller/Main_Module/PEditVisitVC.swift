//
//  PEditVisitVC.swift
//  Preachers
//
//  Created by Abel Anca on 10/14/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import Parse

class PEditVisitVC: UIViewController {

    @IBOutlet var txfBiblicalText: UITextField!
    @IBOutlet var txvMyPreach: UITextView!
    @IBOutlet var txvObservation: UITextView!
    @IBOutlet var datePicker: UIDatePicker!
    
    var objId: String?
    var currentPreach: PFObject?
    var date: String?
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        loadParams()
    }

    // MARK: - Custom Methods
    
    func loadParams() {
        if let objectId = objId {
            let query = PFQuery(className:"Preach")
            query.getObjectInBackgroundWithId(objectId, block: { (object, error) -> Void in
                if error == nil {
                    self.currentPreach = object
                    self.updateParams()
                }
            })
        }
        setCurrentDate(NSDate())
    }
    
    func setCurrentDate(selectedDate: NSDate) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        date = dateFormatter.stringFromDate(selectedDate)
    }
    
    func updateParams() {
        if let preach = currentPreach {
            txfBiblicalText.text        = preach.objectForKey("biblicalText") as? String
            txvMyPreach.text            = preach.objectForKey("myPreach") as? String
            txvObservation.text         = preach.objectForKey("observation") as? String
            
            if let date = preach.objectForKey("date") as? String {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"
                
                if let date = dateFormatter.dateFromString(date) {
                    datePicker.date = date
                }
                self.date = date
            }
        }
    }
    
    // MARK: - API Methods
    
    // MARK: - Action Methods
    @IBAction func btnBack_Action(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnSave_Action(sender: AnyObject) {
        if let preach = currentPreach {
            preach["biblicalText"]         = txfBiblicalText.text
            preach["myPreach"]             = txvMyPreach.text
            preach["observation"]          = txvObservation.text
            preach["date"]                 = date
            preach.saveInBackgroundWithBlock { (success, error) -> Void in
                if error == nil {
                    if success {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
                else {
                    if let error = error {
                        let errorString        = error.userInfo["error"] as! String
                        let alert              = Utils.okAlert("Error", message: errorString)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func datePicker_Action(sender: UIDatePicker) {
        setCurrentDate(sender.date)
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
