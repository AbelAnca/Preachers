//
//  PAddChurchVC.swift
//  Preachers
//
//  Created by Abel Anca on 10/1/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
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
    }
    
    func updateParams() {
    }
    
    // MARK: - API Methods
    
    func saveChurch_APICall() {
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
