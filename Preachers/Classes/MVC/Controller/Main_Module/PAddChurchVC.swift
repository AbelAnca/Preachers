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

class PAddChurchVC: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var txfCity: UITextField!
    @IBOutlet var txfName: UITextField!
    @IBOutlet var txfAddress: UITextField!
    @IBOutlet var txfPastor: UITextField!
    @IBOutlet var txfDistance: UITextField!
    @IBOutlet var txvDescription: UITextView!
    
    @IBOutlet var imgChurch: UIImageView!
    
    let imagePicker                   = UIImagePickerController()
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Custom Methods
    
    func setupUI() {
        imagePicker.delegate          = self
        imgChurch.layer.cornerRadius  = 98
        imgChurch.clipsToBounds       = true
    }
    
    func setupImagePicker() {
        imagePicker.allowsEditing       = false
        imagePicker.sourceType          = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - API Methods
    
    func addChurch_APICall() {
        if txfCity.text?.utf16.count > 1 {
            self.view.endEditing(true)
            KVNProgress.showWithStatus("Adding church...")
            
            if let churchImage = imgChurch.image {
                if let imageData = UIImageJPEGRepresentation(churchImage, 1.0) {
                    let imageFile: PFFile = PFFile(name:"image.jpg", data:imageData)
                    imageFile.saveInBackground()
                    
                    let church = Church()
                    church.city       = self.txfCity.text!
                    church.name       = self.txfName.text
                    church.address    = self.txfAddress.text
                    church.pastor     = self.txfPastor.text
                    church.distance   = self.txfDistance.text
                    church.note       = self.txvDescription.text
                    church.user       = PFUser.currentUser()!
                    church.image      = imageFile
                    church.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if error == nil {
                            if success {
                                self.dismissViewControllerAnimated(true, completion: nil)
                                KVNProgress.dismiss()
                            }
                        }
                        else {
                            if let error = error {
                                KVNProgress.dismiss()
                                
                                let errorString       = error.userInfo["error"] as! String
                                let alert             = Utils.okAlert("Error", message: errorString)
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                        }
                    })
                }
            }
            else {
                let church = Church()
                church.city        = txfCity.text!
                church.name        = txfName.text
                church.address     = txfAddress.text
                church.pastor      = txfPastor.text
                church.distance    = txfDistance.text
                church.note        = txvDescription.text
                church.user        = PFUser.currentUser()!
                church.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if error == nil {
                        if success {
                            self.dismissViewControllerAnimated(true, completion: nil)
                            KVNProgress.dismiss()
                        }
                    }
                    else {
                        if let error = error {
                            KVNProgress.dismiss()
                            
                            let errorString       = error.userInfo["error"] as! String
                            let alert             = Utils.okAlert("Error", message: errorString)
                            self.presentViewController(alert, animated: true, completion: nil)
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
        addChurch_APICall()
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
            imgChurch.image                  = pickedImage
            imgChurch.layer.borderWidth      = 2
            imgChurch.layer.borderColor      = UIColor.preachersBlue().CGColor
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
