//
//  PPreachVC.swift
//  Preachers
//
//  Created by Abel Anca on 10/14/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit

protocol PPreachVCDelegate {
    func didCancelPopover()
    func didEditPreach(_ objectID: String)
}

class PPreachVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var delegate: PPreachVCDelegate?

    @IBOutlet var txfBiblicalText: UITextField!
    @IBOutlet var txfPreach: UITextView!
    @IBOutlet var txfNote: UITextView!
    
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var btnEdit: UIButton!
    
    var objId: String?
    var index: Int?
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //loadParams()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadParams()
    }
    
    // MARK: - Custom Methods
    func updateParams() {
    }
    
    // MARK: - API Methods
    func loadParams() {
    }
    
    // MARK: - Action Methods
    @IBAction func btnBack_Action(_ sender: AnyObject) {
        delegate?.didCancelPopover()
    }
    
    @IBAction func btnEdit_Action(_ sender: AnyObject) {
        if let objectId = objId {
            delegate?.didEditPreach(objectId)
        }
    }
    
    @IBAction func btnShare_Action(_ sender: AnyObject) {
        
    }
    
    @IBAction func btnDelete_Action(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "Attention", message: "Are you sure you want to permanently delete this sermon?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UITextFieldDelegate Methods
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
    // MARK: - UITextViewDelegate Methods
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
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
