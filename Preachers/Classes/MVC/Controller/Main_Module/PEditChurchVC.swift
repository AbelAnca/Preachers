//
//  PAddChurchVC.swift
//  Preachers
//
//  Created by Abel Anca on 10/1/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import Parse
import KVNProgress

class PEditChurchVC: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var txfCity: UITextField!
    @IBOutlet var txfName: UITextField!
    @IBOutlet var txfAddress: UITextField!
    @IBOutlet var txfPastor: UITextField!
    @IBOutlet var txfDistance: UITextField!
    @IBOutlet var txvDescription: UITextView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var imgChurch: UIImageView!
    
    var currentChurch: PFObject?
    var objId: String?
    let imagePicker                    = UIImagePickerController()
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Custom Methods
    
    func setupUI() {
        imagePicker.delegate            = self
        imgChurch.layer.cornerRadius    = 98
        imgChurch.clipsToBounds         = true
        imgChurch.layer.borderWidth     = 2
        imgChurch.layer.borderColor     = UIColor.preachersBlue().CGColor
        
        loadParams()
    }
    
    func setupImagePicker() {
        imagePicker.allowsEditing       = false
        imagePicker.sourceType          = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func loadParams() {
        if let objectId = objId {
            let query = PFQuery(className:"Church")
            query.getObjectInBackgroundWithId(objectId, block: { (object, error) -> Void in
                if error == nil {
                    self.currentChurch = object
                    self.updateParams()
                }
            })
        }
    }
    
    func updateParams() {
        if let church = currentChurch {
            txfCity.text                = church.objectForKey("city") as? String
            txfName.text                = church.objectForKey("name") as? String
            txfAddress.text             = church.objectForKey("address") as? String
            txfPastor.text              = church.objectForKey("pastor") as? String
            txfDistance.text            = church.objectForKey("distance") as? String
            txvDescription.text         = church.objectForKey("note") as? String
            if let userPicture          = church.objectForKey("image") as? PFFile {
                spinner.startAnimating()
                
                userPicture.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    if error == nil {
                        if let imageData = data {
                            let image                 = UIImage(data:imageData)
                            self.imgChurch.image      = image
                            self.spinner.stopAnimating()
                        }
                    }
                    else {
                        self.spinner.stopAnimating()
                    }
                })
            }
        }
    }
    
    // MARK: - API Methods
    
    func saveChurch_APICall() {
        if txfCity.text?.utf16.count > 1 {
            self.view.endEditing(true)
            KVNProgress.showWithStatus("Saving church...")
            
            if let objectId = objId {
                let query = PFQuery(className:"Church")
                query.getObjectInBackgroundWithId(objectId, block: { (object, error) -> Void in
                    if error == nil {
                        if let church = object {
                            church["city"]         = self.txfCity.text!
                            church["name"]         = self.txfName.text
                            church["address"]      = self.txfAddress.text
                            church["pastor"]       = self.txfPastor.text
                            church["distance"]     = self.txfDistance.text
                            church["note"]         = self.txvDescription.text
                            church["user"]         = PFUser.currentUser()!
                            
                            if let imageData = UIImageJPEGRepresentation(self.imgChurch.image!, 1.0) {
                                let imageFile: PFFile = PFFile(name:"image.jpg", data:imageData)
                                imageFile.saveInBackground()
                                church["image"]    = imageFile
                            }
                            
                            church.saveInBackgroundWithBlock({ (success, error) -> Void in
                                if error == nil {
                                    if success {
                                        self.dismissViewControllerAnimated(true, completion: nil)
                                        KVNProgress.dismiss()
                                    }
                                }
                                else {
                                    KVNProgress.dismiss()
                                    if let error = error {
                                        let errorString         = error.userInfo["error"] as! String
                                        let alert               = Utils.okAlert("Error", message: errorString)
                                        self.presentViewController(alert, animated: true, completion: nil)
                                    }
                                }
                            })
                        }
                    }
                })
            }
        }
        else {
            let alert = Utils.okAlert("Upss", message: "The city is required")
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Action Methods
    
    @IBAction func btnAddPhoto_Action(sender: AnyObject) {
        setupImagePicker()
    }
    @IBAction func btnBack_Action(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnSave_Action(sender: AnyObject) {
        saveChurch_APICall()
    }
    
    // MARK: - UITextFieldDelegate Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == txfCity {
            txfName.becomeFirstResponder()
        }
        else
            if textField == txfName {
                txfAddress.becomeFirstResponder()
            }
            else
                if textField == txfAddress {
                    txfPastor.becomeFirstResponder()
                }
                else
                    if textField == txfPastor {
                        txfDistance.becomeFirstResponder()
                    }
                    else
                        if textField == txfDistance {
                            txvDescription.becomeFirstResponder()
        }
        return false
    }
    
    // MARK: - UITextViewDelegate Methods
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            txvDescription.resignFirstResponder()
            return false
        }
        return true
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgChurch.image                     = pickedImage
            imgChurch.layer.borderWidth         = 2
            imgChurch.layer.borderColor         = UIColor.darkGrayColor().CGColor
            
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
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
