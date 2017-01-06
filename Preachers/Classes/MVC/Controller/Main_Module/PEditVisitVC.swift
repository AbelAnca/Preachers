//
//  PEditVisitVC.swift
//  Preachers
//
//  Created by Abel Anca on 10/14/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import Parse

protocol PEditVisitVCDelegate {
    func didCancelEditVC(_ index: Int)
}

class PEditVisitVC: UIViewController {
    
    var delegate: PEditVisitVCDelegate?

    @IBOutlet var txfBiblicalText: UITextField!
    @IBOutlet var txvMyPreach: UITextView!
    @IBOutlet var txvObservation: UITextView!
    @IBOutlet var datePicker: UIDatePicker!
    
    var objId: String?
    var currentPreach: PFObject?
    var date: String?
    var index: Int?
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        loadParams()
    }

    // MARK: - Custom Methods
    
    func loadParams() {
        if let objectId = objId {
            let query = PFQuery(className:"Preach")
            query.getObjectInBackground(withId: objectId, block: { (object, error) -> Void in
                if error == nil {
                    self.currentPreach = object
                    self.updateParams()
                }
            })
        }
        setCurrentDate(Date())
    }
    
    func setCurrentDate(_ selectedDate: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        date = dateFormatter.string(from: selectedDate)
    }
    
    func updateParams() {
        if let preach = currentPreach {
            txfBiblicalText.text        = preach.object(forKey: "biblicalText") as? String
            txvMyPreach.text            = preach.object(forKey: "myPreach") as? String
            txvObservation.text         = preach.object(forKey: "observation") as? String
            
            if let date = preach.object(forKey: "date") as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"
                
                if let date = dateFormatter.date(from: date) {
                    datePicker.date = date
                }
                self.date = date
            }
        }
    }
    
    // MARK: - API Methods
    
    // MARK: - Action Methods
    @IBAction func btnBack_Action(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: { () -> Void in
            if let index = self.index {
                self.delegate?.didCancelEditVC(index)
            }
        })
    }
    
    @IBAction func btnSave_Action(_ sender: AnyObject) {
        if let preach = currentPreach {
            preach["biblicalText"]         = txfBiblicalText.text
            preach["myPreach"]             = txvMyPreach.text
            preach["observation"]          = txvObservation.text
            preach["date"]                 = date
            preach.saveInBackground { (success, error) -> Void in
                if error == nil {
                    if success {
                        self.dismiss(animated: true, completion: { () -> Void in
                            if let index = self.index {
                                self.delegate?.didCancelEditVC(index)
                            }
                        })
                    }
                }
                else {
                    if let error = error {
                        let errorString        = error._userInfo["error"] as! String
                        let alert              = Utils.okAlert("Error", message: errorString)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func datePicker_Action(_ sender: UIDatePicker) {
        setCurrentDate(sender.date)
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
