//
//  PSettingsVC.swift
//  Preachers
//
//  Created by Abel Anca on 9/24/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import Parse
import KVNProgress

class PSettingsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var btnProfile: UIButton!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblEmail: UILabel!
    @IBOutlet var lblBirthdate: UILabel!
    
    let imagePicker = UIImagePickerController()

    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadParams_APICall()
    }

    // MARK: - Custom Methods
    
    func setupUI() {
        btnProfile.imageView?.contentMode       = .scaleAspectFill
        btnProfile.backgroundColor              = UIColor.clear
        btnProfile.layer.cornerRadius           = 62
        btnProfile.layer.borderWidth            = 2
        btnProfile.layer.borderColor            = UIColor.preachersBlue().cgColor
        btnProfile.clipsToBounds                = true
        
        imagePicker.delegate                    = self
    }
    
    func setupImagePicker() {
        imagePicker.allowsEditing               = false
        imagePicker.sourceType                  = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func presentLandingVC() {
        let landVC = self.storyboard?.instantiateViewController(withIdentifier: "PLandingVC_NC") as! UINavigationController
        self.present(landVC, animated: true, completion: nil)
    }
    
    func pushToChangePass() {
        let changePassVC = self.storyboard?.instantiateViewController(withIdentifier: "PChangePassVC") as! PChangePassVC
        self.present(changePassVC, animated: true, completion: nil)
    }
    
    func removeObjectIdFromDefaults() {
        appDelegate.curUserID                    = nil
        appDelegate.defaults.removeObject(forKey: k_UserDef_LoggedInUserID)
        appDelegate.defaults.synchronize()
    }
    
    // MARK: - API Methods
    
    func loadParams_APICall() {
        let currentUser = PFUser.current()
        if currentUser != nil {
            
            if let firstname = currentUser?["firstname"] {
                lblName.text = "\(firstname)"
            }
            
            if let lastname = currentUser?["lastname"] {
                lblName.text = "\(lastname)"
            }
            
            if let firstname = currentUser?["firstname"] {
                if let lastname = currentUser?["lastname"] {
                    lblName.text = "\(firstname) \(lastname)"
                }
            }
            
            if let birthdate = currentUser?["birthdate"] as? String {
                lblBirthdate.text = birthdate
            }

            if let email = currentUser?.email {
                lblEmail.text = email
            }
            
            if let userPicture = currentUser?["profilePicture"] as? PFFile {
                userPicture.getDataInBackground(block: { (data, error) -> Void in
                    if error == nil {
                        if let imageData = data {
                            let image = UIImage(data:imageData)
                            self.btnProfile.setImage(image, for: UIControlState())
                        }
                    }
                    else {
                        self.spinner.stopAnimating()
                    }
                })
            }
        }
    }
    
    // MARK: - Action Methods
    
    @IBAction func btnChangeUsername_Action(_ sender: AnyObject) {
        let changeUsernameVC = storyboard?.instantiateViewController(withIdentifier: "PChangeUsernameVC") as! PChangeUsernameVC
        present(changeUsernameVC, animated: true, completion: nil)
    }

    @IBAction func btnProfile_Action(_ sender: AnyObject) {
        setupImagePicker()
    }
    
    @IBAction func btnEditProfile_Action(_ sender: AnyObject) {
        let editVC = storyboard?.instantiateViewController(withIdentifier: "PEditProfileVC") as! PEditProfileVC
        self.present(editVC, animated: true, completion: nil)
    }
    
    @IBAction func btnChangePass_Action(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "Important!", message: "Do you want to change your password?", preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            
            let currentUser = PFUser.current()
            if let email = currentUser?.email {
                KVNProgress.show(withStatus: "Reseting...")
                PFUser.requestPasswordResetForEmail(inBackground: email, block: { (success, error) -> Void in
                    if error == nil {
                        if success {
                            self.pushToChangePass()
                            KVNProgress.dismiss()
                        }
                    }
                    else {
                        if let error = error {
                            KVNProgress.dismiss()
                            
                            let errorString              = error.userInfo["error"] as! String
                            let alert                    = Utils.okAlert("Error", message: errorString)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnLogout_Action(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "Important!", message: "Are you sure you want to Logout?", preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            
            KVNProgress.show(withStatus: "Logout...")
            PFUser.logOutInBackground(block: { (error) -> Void in
                if error == nil {
                    self.removeObjectIdFromDefaults()
                    self.presentLandingVC()
                    
                    KVNProgress.dismiss()
                }
                else {
                    if let error = error {
                        KVNProgress.dismiss()
                        
                        let errorString          = error.userInfo["error"] as! String
                        let alert                = Utils.okAlert("Error", message: errorString)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            })
            KVNProgress.dismiss()
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let currentUser = PFUser.current()
            if currentUser != nil {
                self.spinner.startAnimating()
                
                if let imageData           = UIImageJPEGRepresentation(pickedImage, 1.0) {
                    let imageFile          = PFFile(name:"image.jpg", data:imageData)
                    
                    imageFile?.saveInBackground(block: { (success, error) -> Void in
                        if error == nil {
                            if success {
                                currentUser?.setObject(imageFile, forKey: "profilePicture")
                                currentUser?.saveInBackground(block: { (succeded, error) -> Void in
                                    if succeded {
                                        self.loadParams_APICall()
                                        self.spinner.stopAnimating()
                                    }
                                })
                            }
                        }
                        else {
                            if let error = error {
                                self.spinner.stopAnimating()
                                
                                let errorString        = error.userInfo["error"] as! String
                                let alert              = Utils.okAlert("Error", message: errorString)
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                        }
                    })
                }
            }
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
    
    // Example
    class func scaleImageDown(_ image: UIImage) -> UIImage {
        let fWidth      = image.size.width
        let fHeight     = image.size.height
        var bounds      = CGRect.zero
        
        if fWidth <= k_ResizeTo30PercentResolution && fHeight <= k_ResizeTo30PercentResolution {
            return image
        }
        else {
            let ratio: CGFloat          = fWidth/fHeight
              if ratio > 1 {
                bounds.size.width       = k_ResizeTo30PercentResolution
                bounds.size.height      = k_ResizeTo30PercentResolution / ratio
            }
            else {
                bounds.size.height      = k_ResizeTo30PercentResolution
                bounds.size.width       = k_ResizeTo30PercentResolution * ratio
            }
        }
        
        let size = CGSize(width: bounds.size.width, height: bounds.size.height)
        let hasAlpha = false
        let scale: CGFloat = 2.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return scaledImage!
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
