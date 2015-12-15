//
//  PLandingVC.swift
//  Preachers
//
//  Created by Abel Anca on 9/18/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import Parse

class PLandingVC: UIViewController {

    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _ = appDelegate.curUserID {
            showMomentsVC()
        }
        else {
            showLoginVC()
        }
        
    }
    
    // MARK: - Public Methods
    
    // MARK: - Custom Methods
    func showLoginVC() {
        let navC        = appDelegate.storyboardLogin.instantiateViewControllerWithIdentifier("PLandingVC_NC") as! UINavigationController
        self.navigationController?.presentViewController(navC, animated: true, completion: nil)
    }
    
    func showMomentsVC() {
        let mainVC         = self.storyboard?.instantiateViewControllerWithIdentifier("PMainVC_TB") as! UITabBarController
        self.navigationController?.presentViewController(mainVC, animated: true, completion: nil)
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
