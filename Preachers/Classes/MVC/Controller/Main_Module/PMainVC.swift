//
//  PMainVC.swift
//  Preachers
//
//  Created by Abel Anca on 9/18/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import Parse

class PMainVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var vireTopBar: UIView!
    @IBOutlet var constraints: NSLayoutConstraint!
    @IBOutlet var btnEdit: UIButton!
    @IBOutlet var tblView: UITableView!
    @IBOutlet var viewTutorial: UIView!
    
    var searchArrChurchs: [PFObject]?
    var arrChurchs: [PFObject]?
    
    var isEdit                 = false
    var isSearching            = false

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
        tblView.tableFooterView = UIView()
    }

    func filterList() {
        if isSearching == false {
            if var _ = arrChurchs {
                arrChurchs!.sortInPlace {
                    return $1["city"] as! String > $0["city"] as! String
                }
                tblView.reloadData()
            }
        }
        else {
            if var _ = searchArrChurchs {
                searchArrChurchs!.sortInPlace {
                    return $1["city"] as! String > $0["city"] as! String
                }
                tblView.reloadData()
            }
        }
    }
    
    func searching(searchText: String) {
        if searchBar.text!.isEmpty {
            isSearching                  = false
            tblView.reloadData()
        } else {
            isSearching                  =  true
            searchArrChurchs?.removeAll()
            if let churchs = arrChurchs {
                for var index = 0; index < churchs.count; index++
                {
                    let church           = churchs[index]
                    
                    if let city = church["city"] {
                        if city.lowercaseString.rangeOfString(searchText.lowercaseString)  != nil {
                            searchArrChurchs?.append((arrChurchs?[index])!)
                        }
                    }
                }
            }
        }
        tblView.reloadData()
    }
    
    // MARK: - API Methods
    func loadParams_APICall() {
        let query                           = PFQuery(className:"Church")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                self.arrChurchs             = objects
                self.searchArrChurchs       = objects
                self.filterList()
                self.tblView.reloadData()
            }
        }
    }
    
    
    // MARK: - Action Methods
    
    @IBAction func btnEdit_Action(sender: AnyObject) {
        if isEdit == false {
            isEdit               = true
            tblView.editing      = true
        }
        else {
            isEdit               = false
            tblView.editing      = false
        }
    }
    
    @IBAction func btnAddChurch_Action(sender: AnyObject) {
        let addChurchVC = storyboard?.instantiateViewControllerWithIdentifier("PAddChurchVC") as! PAddChurchVC
        presentViewController(addChurchVC, animated: true, completion: nil)
    }

    
    // MARK: - UITableViewDelegate Methods
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            let query = PFQuery(className:"Church")
            query.whereKey("user", equalTo: PFUser.currentUser()!)
            query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                if error == nil {
                    if let objects = objects {
                        let object = objects[indexPath.row]
                        object.deleteInBackground()
                        
                        let query = PFQuery(className:"Preach")
                        
                        query.whereKey("church", equalTo: object)
                        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                            if error == nil {
                                if let obj = objects {
                                    for objec in obj {
                                        objec.deleteInBackground()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            arrChurchs?.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchBar.text = ""
        
        if isEdit == true {
            if isSearching == true {
                let editChurchVC         = self.storyboard?.instantiateViewControllerWithIdentifier("PEditChurchVC") as! PEditChurchVC
                if let churchs           = searchArrChurchs {
                    let church           = churchs[indexPath.row]
                    editChurchVC.objId   = church.objectId
                }
                self.presentViewController(editChurchVC, animated: true, completion: nil)
            }
            else {
                let editChurchVC         = self.storyboard?.instantiateViewControllerWithIdentifier("PEditChurchVC") as! PEditChurchVC
                if let churchs           = arrChurchs {
                    let church           = churchs[indexPath.row]
                    editChurchVC.objId   = church.objectId
                }
                self.presentViewController(editChurchVC, animated: true, completion: nil)
            }
        }
        else {
            if isSearching == true {
                let churchVC             = self.storyboard?.instantiateViewControllerWithIdentifier("PChurchVC") as! PChurchVC
                if let churchs           = searchArrChurchs {
                    let church           = churchs[indexPath.row]
                    churchVC.objId       = church.objectId
                }
                churchVC.modalTransitionStyle = .CrossDissolve
                self.showViewController(churchVC, sender: nil)
            }
            else {
                let churchVC             = self.storyboard?.instantiateViewControllerWithIdentifier("PChurchVC") as! PChurchVC
                if let churchs           = arrChurchs {
                    let church           = churchs[indexPath.row]
                    churchVC.objId       = church.objectId
                }
                churchVC.modalTransitionStyle = .CrossDissolve
                self.showViewController(churchVC, sender: nil)
            }
        }
    }
    
    // MARK: - UITableViewDataSource Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let churchs = arrChurchs {
            if churchs.count == 0 {
                searchBar.hidden = true
                viewTutorial.hidden = false
            }
            else {
                searchBar.hidden = false
                viewTutorial.hidden = true
            }
        }
        
        if isSearching == true {
            if let searchChurchs = searchArrChurchs {
                if searchChurchs.count == 0 {
                    btnEdit.hidden      = true
                }
                else {
                    btnEdit.hidden      = false
                }
                
                return searchChurchs.count
            }
        }
        else {
            if let churchs = arrChurchs {
                if churchs.count == 0 {
                    btnEdit.hidden      = true
                }
                else {
                    btnEdit.hidden      = false
                }
                return churchs.count
            }
        }
        

        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PChurchCell", forIndexPath: indexPath) as! PChurchCell
        
        if isSearching == true {
            if let churchs = searchArrChurchs {
                let church                  = churchs[indexPath.row]
                cell.lblName.text           = church.objectForKey("city") as? String
                cell.lblSubtitle.text       = church.objectForKey("name") as? String
                
                if let userPicture = church.objectForKey("image") as? PFFile {
                    userPicture.getDataInBackgroundWithBlock({ (data, error) -> Void in
                        if error == nil {
                            if let imageData = data {
                                let image           = UIImage(data:imageData)
                                cell.imgView.image  = image
                            }
                        }
                    })
                }
            }

        }
        else {
            if let churchs = arrChurchs {
                let church                  = churchs[indexPath.row]
                cell.lblName.text           = church.objectForKey("city") as? String
                cell.lblSubtitle.text       = church.objectForKey("name") as? String
                
                if let userPicture = church.objectForKey("image") as? PFFile {
                    userPicture.getDataInBackgroundWithBlock({ (data, error) -> Void in
                        if error == nil {
                            if let imageData = data {
                                let image           = UIImage(data:imageData)
                                cell.imgView.image  = image
                            }
                        }
                    })
                }
            }
        }
        return cell
    }
    
    // MARK: - UISearchBarDelegate Methods
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searching(searchText)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton        = false
        constraints.constant               = 0.0
        self.vireTopBar.hidden             = false
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }) { (finished) -> Void in
        }
        searchBar.text = ""
        
        if let searchText = searchBar.text {
            searching(searchText)
        }
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        
        searchBar.showsCancelButton         = true
        constraints.constant                = -44
        
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }) { (finished) -> Void in
                self.vireTopBar.hidden      = true
        }
        return true
    }
    
    // MARK: - StatusBar Methods
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if constraints.constant == 0 {
            return UIStatusBarStyle.LightContent
        }
        return UIStatusBarStyle.Default
    }

    // MARK: - MemoryManagement Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
