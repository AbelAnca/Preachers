//
//  PPreachVC.swift
//  Preachers
//
//  Created by Abel Anca on 10/14/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import Parse

protocol PPreachVCDelegate {
    func didCancelPopover()
    func didEditPreach(objectID: String)
}

class PPreachVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var delegate: PPreachVCDelegate?

    @IBOutlet var txfBiblicalText: UITextField!
    @IBOutlet var txfPreach: UITextView!
    @IBOutlet var txfNote: UITextView!
    
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var btnEdit: UIButton!
    
    var objId: String?
    var currentPreach: PFObject?
    var currentChurch: PFObject?
    var index: Int?
    
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
        delegate?.didCancelPopover()
    }
    
    @IBAction func btnEdit_Action(sender: AnyObject) {
        if let objectId = objId {
            delegate?.didEditPreach(objectId)
        }
    }
    
    @IBAction func btnShare_Action(sender: AnyObject) {
        
    }
    
    @IBAction func btnDelete_Action(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Attention", message: "Are you sure you want to permanently delete this sermon?", preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { (action) -> Void in
            let query = PFQuery(className:"Preach")
            if let church = self.currentChurch {
                query.whereKey("church", equalTo: church)
                query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                    if error == nil {
                        if let index = self.index {
                            if let objects = objects {
                                let object = objects[index]
                                object.deleteInBackground()
                                self.delegate?.didCancelPopover()
                            }
                        }
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
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
