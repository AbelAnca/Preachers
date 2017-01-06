//
//  PEditVisitVC.swift
//  Preachers
//
//  Created by Abel Anca on 10/14/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit

protocol PEditVisitVCDelegate {
    func didCancelEditVC(_ index: Int)
}

class PEditVisitVC: UIViewController {
    
    var delegate: PEditVisitVCDelegate?

    @IBOutlet var txfBiblicalText: UITextField!
    @IBOutlet var txvMyPreach: UITextView!
    @IBOutlet var txvObservation: UITextView!
    @IBOutlet var datePicker: UIDatePicker!
    
    var objId: String?
    var date: String?
    var index: Int?
    
    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        loadParams()
    }

    // MARK: - Custom Methods
    
    func loadParams() {
        setCurrentDate(Date())
    }
    
    func setCurrentDate(_ selectedDate: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        date = dateFormatter.string(from: selectedDate)
    }
    
    func updateParams() {
    }
    
    // MARK: - API Methods
    
    // MARK: - Action Methods
    @IBAction func btnBack_Action(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: { () -> Void in
            if let index = self.index {
                self.delegate?.didCancelEditVC(index)
            }
        })
    }
    
    @IBAction func btnSave_Action(_ sender: AnyObject) {
    }
    
    @IBAction func datePicker_Action(_ sender: UIDatePicker) {
        setCurrentDate(sender.date)
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
