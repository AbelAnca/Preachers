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

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
        imgChurch.layer.borderColor     = UIColor.preachersBlue().cgColor
        
        loadParams()
    }
    
    func setupImagePicker() {
        imagePicker.allowsEditing       = false
        imagePicker.sourceType          = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func loadParams() {
        if let objectId = objId {
            let query = PFQuery(className:"Church")
            query.getObjectInBackground(withId: objectId, block: { (object, error) -> Void in
                if error == nil {
                    self.currentChurch = object
                    self.updateParams()
                }
            })
        }
    }
    
    func updateParams() {
        if let church = currentChurch {
            txfCity.text                = church.object(forKey: "city") as? String
            txfName.text                = church.object(forKey: "name") as? String
            txfAddress.text             = church.object(forKey: "address") as? String
            txfPastor.text              = church.object(forKey: "pastor") as? String
            txfDistance.text            = church.object(forKey: "distance") as? String
            txvDescription.text         = church.object(forKey: "note") as? String
            if let userPicture          = church.object(forKey: "image") as? PFFile {
                spinner.startAnimating()
                
                userPicture.getDataInBackground(block: { (data, error) -> Void in
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
            KVNProgress.show(withStatus: "Saving church...")
            
            if let objectId = objId {
                let query = PFQuery(className:"Church")
                query.getObjectInBackground(withId: objectId, block: { (object, error) -> Void in
                    if error == nil {
                        if let church = object {
                            church["city"]         = self.txfCity.text!
                            church["name"]         = self.txfName.text
                            church["address"]      = self.txfAddress.text
                            church["pastor"]       = self.txfPastor.text
                            church["distance"]     = self.txfDistance.text
                            church["note"]         = self.txvDescription.text
                            church["user"]         = PFUser.current()!
                            
                            if let imageData = UIImageJPEGRepresentation(self.imgChurch.image!, 1.0) {
                                let imageFile: PFFile = PFFile(name:"image.jpg", data:imageData)!
                                imageFile.saveInBackground()
                                church["image"]    = imageFile
                            }
                            
                            church.saveInBackground(block: { (success, error) -> Void in
                                if error == nil {
                                    if success {
                                        self.dismiss(animated: true, completion: nil)
                                        KVNProgress.dismiss()
                                    }
                                }
                                else {
                                    KVNProgress.dismiss()
                                    if let error = error {
                                        let errorString         = error._userInfo["error"] as! String
                                        let alert               = Utils.okAlert("Error", message: errorString)
                                        self.present(alert, animated: true, completion: nil)
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
            present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Action Methods
    
    @IBAction func btnAddPhoto_Action(_ sender: AnyObject) {
        setupImagePicker()
    }
    @IBAction func btnBack_Action(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSave_Action(_ sender: AnyObject) {
        saveChurch_APICall()
    }
    
    // MARK: - UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            txvDescription.resignFirstResponder()
            return false
        }
        return true
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgChurch.image                     = pickedImage
            imgChurch.layer.borderWidth         = 2
            imgChurch.layer.borderColor         = UIColor.darkGray.cgColor
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
