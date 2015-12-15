//
//  PPreachVC.swift
//  Preachers
//
//  Created by Abel Anca on 10/14/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import Parse

class PPreachVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet var txfBiblicalText: UITextField!
    @IBOutlet var txfPreach: UITextView!
    @IBOutlet var txfNote: UITextView!
    
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var btnEdit: UIButton!
    
    var objId: String?
    var currentPreach: PFObject?
    
    var isEdit                 = false
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //loadParams()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadParams()
    }
    
    // MARK: - Custom Methods
    func updateParams() {
        if let preach = currentPreach {
            txfBiblicalText.text            = preach.objectForKey("biblicalText") as? String
            txfNote.text                    = preach.objectForKey("observation") as? String
            txfPreach.text                  = preach.objectForKey("myPreach") as? String
        }
    }
    
    // MARK: - API Methods
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
    }
    
    // MARK: - Action Methods
    @IBAction func btnBack_Action(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnEdit_Action(sender: AnyObject) {
        let editChurchVC         = self.storyboard?.instantiateViewControllerWithIdentifier("PEditVisitVC") as! PEditVisitVC
        if let preach            = currentPreach {
            editChurchVC.objId   = preach.objectId
        }
        
        presentViewController(editChurchVC, animated: true, completion: nil)
    }
    
    // MARK: - UITextFieldDelegate Methods
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return false
    }
    
    // MARK: - UITextViewDelegate Methods
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
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
