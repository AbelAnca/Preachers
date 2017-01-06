//
//  PMainVC.swift
//  Preachers
//
//  Created by Abel Anca on 9/18/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit

class PMainVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var vireTopBar: UIView!
    @IBOutlet var constraints: NSLayoutConstraint!
    @IBOutlet var btnEdit: UIButton!
    @IBOutlet var tblView: UITableView!
    @IBOutlet var viewTutorial: UIView!
    
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
    }
    
    func searching(_ searchText: String) {
        tblView.reloadData()
    }
    
    // MARK: - API Methods
    func loadParams_APICall() {
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
            
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.text = ""
        
    }
    
    // MARK: - UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PChurchCell", for: indexPath) as! PChurchCell
        
       
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
