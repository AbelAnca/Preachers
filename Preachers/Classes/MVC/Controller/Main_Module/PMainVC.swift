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
    
    override func viewWillAppear(_ animated: Bool) {
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
                arrChurchs!.sort {
                    return $1["city"] as! String > $0["city"] as! String
                }
                tblView.reloadData()
            }
        }
        else {
            if var _ = searchArrChurchs {
                searchArrChurchs!.sort {
                    return $1["city"] as! String > $0["city"] as! String
                }
                tblView.reloadData()
            }
        }
    }
    
    func searching(_ searchText: String) {
        if searchBar.text!.isEmpty {
            isSearching                  = false
            tblView.reloadData()
        } else {
            isSearching                  =  true
            searchArrChurchs?.removeAll()
            if let churchs = arrChurchs {
                for index in 0 ..< churchs.count
                {
                    let church           = churchs[index]
                    
                    if let city = church["city"] {
                        if (city as AnyObject).lowercased.range(of: searchText.lowercased())  != nil {
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
        query.whereKey("user", equalTo: PFUser.current()!)
        query.findObjectsInBackground { (objects, error) -> Void in
            if error == nil {
                self.arrChurchs             = objects
                self.searchArrChurchs       = objects
                self.filterList()
                self.tblView.reloadData()
            }
        }
    }
    
    
    // MARK: - Action Methods
    
    @IBAction func btnEdit_Action(_ sender: AnyObject) {
        if isEdit == false {
            isEdit               = true
            tblView.isEditing      = true
        }
        else {
            isEdit               = false
            tblView.isEditing      = false
        }
    }
    
    @IBAction func btnAddChurch_Action(_ sender: AnyObject) {
        let addChurchVC = storyboard?.instantiateViewController(withIdentifier: "PAddChurchVC") as! PAddChurchVC
        present(addChurchVC, animated: true, completion: nil)
    }

    
    // MARK: - UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            let query = PFQuery(className:"Church")
            query.whereKey("user", equalTo: PFUser.current()!)
            query.findObjectsInBackground { (objects, error) -> Void in
                if error == nil {
                    if let objects = objects {
                        let object = objects[indexPath.row]
                        object.deleteInBackground()
                        
                        let query = PFQuery(className:"Preach")
                        
                        query.whereKey("church", equalTo: object)
                        query.findObjectsInBackground { (objects, error) -> Void in
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
            
            arrChurchs?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.text = ""
        
        if isEdit == true {
            if isSearching == true {
                let editChurchVC         = self.storyboard?.instantiateViewController(withIdentifier: "PEditChurchVC") as! PEditChurchVC
                if let churchs           = searchArrChurchs {
                    let church           = churchs[indexPath.row]
                    editChurchVC.objId   = church.objectId
                }
                self.present(editChurchVC, animated: true, completion: nil)
            }
            else {
                let editChurchVC         = self.storyboard?.instantiateViewController(withIdentifier: "PEditChurchVC") as! PEditChurchVC
                if let churchs           = arrChurchs {
                    let church           = churchs[indexPath.row]
                    editChurchVC.objId   = church.objectId
                }
                self.present(editChurchVC, animated: true, completion: nil)
            }
        }
        else {
            if isSearching == true {
                let churchVC             = self.storyboard?.instantiateViewController(withIdentifier: "PChurchVC") as! PChurchVC
                if let churchs           = searchArrChurchs {
                    let church           = churchs[indexPath.row]
                    churchVC.objId       = church.objectId
                }
                churchVC.modalTransitionStyle = .crossDissolve
                self.show(churchVC, sender: nil)
            }
            else {
                let churchVC             = self.storyboard?.instantiateViewController(withIdentifier: "PChurchVC") as! PChurchVC
                if let churchs           = arrChurchs {
                    let church           = churchs[indexPath.row]
                    churchVC.objId       = church.objectId
                }
                churchVC.modalTransitionStyle = .crossDissolve
                self.show(churchVC, sender: nil)
            }
        }
    }
    
    // MARK: - UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let churchs = arrChurchs {
            if churchs.count == 0 {
                searchBar.isHidden = true
                viewTutorial.isHidden = false
            }
            else {
                searchBar.isHidden = false
                viewTutorial.isHidden = true
            }
        }
        
        if isSearching == true {
            if let searchChurchs = searchArrChurchs {
                if searchChurchs.count == 0 {
                    btnEdit.isHidden      = true
                }
                else {
                    btnEdit.isHidden      = false
                }
                
                return searchChurchs.count
            }
        }
        else {
            if let churchs = arrChurchs {
                if churchs.count == 0 {
                    btnEdit.isHidden      = true
                }
                else {
                    btnEdit.isHidden      = false
                }
                return churchs.count
            }
        }
        

        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PChurchCell", for: indexPath) as! PChurchCell
        
        if isSearching == true {
            if let churchs = searchArrChurchs {
                let church                  = churchs[indexPath.row]
                cell.lblName.text           = church.object(forKey: "city") as? String
                cell.lblSubtitle.text       = church.object(forKey: "name") as? String
                
                if let userPicture = church.object(forKey: "image") as? PFFile {
                    userPicture.getDataInBackground(block: { (data, error) -> Void in
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
                cell.lblName.text           = church.object(forKey: "city") as? String
                cell.lblSubtitle.text       = church.object(forKey: "name") as? String
                
                if let userPicture = church.object(forKey: "image") as? PFFile {
                    userPicture.getDataInBackground(block: { (data, error) -> Void in
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searching(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton        = false
        constraints.constant               = 0.0
        self.vireTopBar.isHidden             = false
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: { (finished) -> Void in
        }) 
        searchBar.text = ""
        
        if let searchText = searchBar.text {
            searching(searchText)
        }
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        searchBar.showsCancelButton         = true
        constraints.constant                = -44
        
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: { (finished) -> Void in
                self.vireTopBar.isHidden      = true
        }) 
        return true
    }
    
    // MARK: - StatusBar Methods
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if constraints.constant == 0 {
            return UIStatusBarStyle.lightContent
        }
        return UIStatusBarStyle.default
    }

    // MARK: - MemoryManagement Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
