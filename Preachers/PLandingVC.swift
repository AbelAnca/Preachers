//
//  PLandingVC.swift
//  Preachers
//
//  Created by Abel Anca on 9/18/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit

class PLandingVC: UIViewController {

    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
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
        let navC        = appDelegate.storyboardLogin.instantiateViewController(withIdentifier: "PLandingVC_NC") as! UINavigationController
        self.navigationController?.present(navC, animated: true, completion: nil)
    }
    
    func showMomentsVC() {
        let mainVC         = self.storyboard?.instantiateViewController(withIdentifier: "PMainVC_TB") as! UITabBarController
        self.navigationController?.present(mainVC, animated: true, completion: nil)
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
