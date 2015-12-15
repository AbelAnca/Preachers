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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadParams_APICall()
    }

    // MARK: - Custom Methods
    
    func setupUI() {
        btnProfile.imageView?.contentMode       = .ScaleAspectFill
        btnProfile.backgroundColor              = UIColor.clearColor()
        btnProfile.layer.cornerRadius           = 62
        btnProfile.layer.borderWidth            = 2
        btnProfile.layer.borderColor            = UIColor.preachersBlue().CGColor
        btnProfile.clipsToBounds                = true
        
        imagePicker.delegate                    = self
    }
    
    func setupImagePicker() {
        imagePicker.allowsEditing               = false
        imagePicker.sourceType                  = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func presentLandingVC() {
        let landVC = self.storyboard?.instantiateViewControllerWithIdentifier("PLandingVC_NC") as! UINavigationController
        self.presentViewController(landVC, animated: true, completion: nil)
    }
    
    func pushToChangePass() {
        let changePassVC = self.storyboard?.instantiateViewControllerWithIdentifier("PChangePassVC") as! PChangePassVC
        self.presentViewController(changePassVC, animated: true, completion: nil)
    }
    
    func removeObjectIdFromDefaults() {
        appDelegate.curUserID                    = nil
        appDelegate.defaults.removeObjectForKey(k_UserDef_LoggedInUserID)
        appDelegate.defaults.synchronize()
    }
    
    // MARK: - API Methods
    
    func loadParams_APICall() {
        let currentUser = PFUser.currentUser()
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
                userPicture.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    if error == nil {
                        if let imageData = data {
                            let image = UIImage(data:imageData)
                            self.btnProfile.setImage(image, forState: .Normal)
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
    
    @IBAction func btnChangeUsername_Action(sender: AnyObject) {
        let changeUsernameVC = storyboard?.instantiateViewControllerWithIdentifier("PChangeUsernameVC") as! PChangeUsernameVC
        presentViewController(changeUsernameVC, animated: true, completion: nil)
    }

    @IBAction func btnProfile_Action(sender: AnyObject) {
        setupImagePicker()
    }
    
    @IBAction func btnEditProfile_Action(sender: AnyObject) {
        let editVC = storyboard?.instantiateViewControllerWithIdentifier("PEditProfileVC") as! PEditProfileVC
        self.presentViewController(editVC, animated: true, completion: nil)
    }
    
    @IBAction func btnChangePass_Action(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Important!", message: "Do you want to change your password?", preferredStyle:.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            let currentUser = PFUser.currentUser()
            if let email = currentUser?.email {
                KVNProgress.showWithStatus("Reseting...")
                PFUser.requestPasswordResetForEmailInBackground(email, block: { (success, error) -> Void in
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
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                })
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnLogout_Action(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Important!", message: "Are you sure you want to Logout?", preferredStyle:.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            KVNProgress.showWithStatus("Logout...")
            PFUser.logOutInBackgroundWithBlock({ (error) -> Void in
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
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
            })
            KVNProgress.dismiss()
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let currentUser = PFUser.currentUser()
            if currentUser != nil {
                self.spinner.startAnimating()
                
                if let imageData           = UIImageJPEGRepresentation(pickedImage, 1.0) {
                    let imageFile          = PFFile(name:"image.jpg", data:imageData)
                    
                    imageFile.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if error == nil {
                            if success {
                                currentUser?.setObject(imageFile, forKey: "profilePicture")
                                currentUser?.saveInBackgroundWithBlock({ (succeded, error) -> Void in
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
    
    // Example
    class func scaleImageDown(image: UIImage) -> UIImage {
        let fWidth      = image.size.width
        let fHeight     = image.size.height
        var bounds      = CGRectZero
        
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
        
        let size = CGSizeMake(bounds.size.width, bounds.size.height)
        let hasAlpha = false
        let scale: CGFloat = 2.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return scaledImage
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
