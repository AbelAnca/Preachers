//
//  PChurchVC.swift
//  Preachers
//
//  Created by Abel Anca on 11/16/15.
//  Copyright © 2015 Abel Anca. All rights reserved.
//

import UIKit
import Parse
import MapKit
import WYPopoverController
import CoreLocation

enum PChurchTab: Int {
    case Visits, Place, Details
}

class PChurchVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, WYPopoverControllerDelegate, PPreachVCDelegate, PEditVisitVCDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    lazy var popover                = WYPopoverController()
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var imgChurch: UIImageView!
    
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblCity: UILabel!
    @IBOutlet var lblPastor: UILabel!
    @IBOutlet var lblAddress: UILabel!
    
    @IBOutlet var lblNote: UITextView!
    
    @IBOutlet var btnAddVisit: UIButton!
    @IBOutlet var btnShowSearchBar: UIButton!
    
    @IBOutlet var viewVisits: UIView!
    @IBOutlet var viewPlace: UIView!
    @IBOutlet var viewDetails: UIView!
    @IBOutlet var viewBackgroundImgChurch: UIView!
    
    @IBOutlet var constraintsOfPlace: NSLayoutConstraint!
    
    @IBOutlet var segmentControl: ADVSegmentedControl!
    
    @IBOutlet var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    var searchController:UISearchController!
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    var arrPreaches: [PFObject]?
    var currentChurch: PFObject?
    var index: Int?
    
    var nrVisits: Int?
    var objId: String?

    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMapView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadParams()
    }
    
    // MARK: - Custom Methods
    
    func setupUI() {
        imgChurch.backgroundColor              = UIColor.clearColor()
        imgChurch.layer.cornerRadius           = 75
        imgChurch.layer.borderWidth            = 6
        imgChurch.layer.borderColor            = UIColor.whiteColor().CGColor
        imgChurch.clipsToBounds                = true
        
        viewBackgroundImgChurch.layer.cornerRadius = 69
        viewBackgroundImgChurch.clipsToBounds      = true
        
        btnShowSearchBar.layer.cornerRadius        = 20
        btnShowSearchBar.clipsToBounds             = true
        
        
        loadScreenForCurSelectedTab()
    }
    
    func setupMapView() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
    }
    
    private func loadScreenForCurSelectedTab() {
        if curSelectedTab() == PChurchTab.Visits.rawValue {
            viewVisits.hidden = false
            viewPlace.hidden = true
            viewDetails.hidden = true
        }
        else
            if curSelectedTab() == PChurchTab.Place.rawValue {
                viewVisits.hidden = true
                viewPlace.hidden = true
                viewDetails.hidden = false
        }
        else
                if curSelectedTab() == PChurchTab.Details.rawValue {
                    viewVisits.hidden = true
                    viewPlace.hidden = false
                    viewDetails.hidden = true
        }
    }
    
    private func curSelectedTab() -> Int {
        return segmentControl.selectedIndex
    }
    
    func loadParams() {
        if let objectId = objId {
            let query = PFQuery(className:"Church")
            query.getObjectInBackgroundWithId(objectId, block: { (object, error) -> Void in
                if error == nil {
                    self.currentChurch = object
                    self.updateParams()
                    self.loadPreach()
                }
            })
        }
    }
    
    func updateParams() {
        if let church = currentChurch {
            
            let name = church.objectForKey("name") as? String
            if let name = name {
                lblName.text = "\(name)"
            }
            
            let city = church.objectForKey("city") as? String
            if let city = city {
                lblCity.text = "\(city)"
            }
            
            let address = church.objectForKey("address") as? String
            if let address = address {
                lblAddress.text     = "\(address)"
            }
            
//            let distance = church.objectForKey("distance") as? String
//            if let distance = distance {
//                lblDistance.text    = "\(distance)"
//            }
            
            let pastor = church.objectForKey("pastor") as? String
            if let pastor = pastor {
                lblPastor.text          = "\(pastor)"
            }
            
            let note = church.objectForKey("note") as? String
            if let note = note {
                lblNote.text        = note
            }
            
            if let userPicture = church.objectForKey("image") as? PFFile {
                userPicture.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    if error == nil {
                        if let imageData = data {
                            if let image = UIImage(data:imageData) {
                                if image.size == CGSizeMake(200, 200) {
                                    self.imgChurch.backgroundColor  = UIColor.blackColor()
                                    self.imgChurch.image            = UIImage(named: "churchICO")
                                }
                                else {
                                    self.imgChurch.image            = image
                                }
                            }
                        }
                    }
                    else {
                    }
                })
            }
        }
    }

    // MARK: - API Methods
    
    func loadPreach() {
        let query = PFQuery(className:"Preach")
        if let church = currentChurch {
            query.whereKey("church", equalTo: church)
            query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                if error == nil {
                    self.nrVisits         = objects?.count
                    self.arrPreaches      = objects
                    
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let churchs = arrPreaches {
            return churchs.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PPreachCell", forIndexPath: indexPath) as! PPreachCell
        
        if let preaches = arrPreaches {
            let preach              = preaches[indexPath.row]
            let date                = preach.objectForKey("date") as? String
            let  biblicalText = preach.objectForKey("biblicalText") as? String
            
            if let date = date {
                cell.lblDate.text       = "\(date)"
            }
            
            if let biblicalText = biblicalText {
                cell.lblBiblicalText.text = "\(biblicalText)"
            }
        }
        return cell

    }
    
    func selectItemAtIndex(index: Int) {
        let editChurchVC         = self.storyboard?.instantiateViewControllerWithIdentifier("PPreachVC") as! PPreachVC
        if let preachs           = arrPreaches {
            let preach           = preachs[index]
            editChurchVC.objId   = preach.objectId
        }
        
        if let ind = self.index {
            editChurchVC.index = ind
        }
        
        if let currentChurch = currentChurch {
            editChurchVC.currentChurch = currentChurch
        }
        editChurchVC.delegate    = self
        
        let grayColor                               = UIColor.color(26, green: 26, blue: 26, alpha: 1)
        
        let popoverBackgroundView                   = WYPopoverBackgroundView.appearance()
        popoverBackgroundView.tintColor             = grayColor
        popoverBackgroundView.fillTopColor          = grayColor
        popoverBackgroundView.fillBottomColor       = grayColor
        popoverBackgroundView.outerStrokeColor      = UIColor.clearColor()
        popoverBackgroundView.innerStrokeColor      = UIColor.clearColor()
        
        popover                                     = WYPopoverController(contentViewController: editChurchVC)
        popover.delegate                            = self
        popover.presentPopoverFromRect(self.view.bounds, inView: self.view, permittedArrowDirections: .None, animated: true)
    }
    
    // MARK: - UICollectionViewDelegate Methods
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.index = indexPath.row
        selectItemAtIndex(indexPath.row)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        // width of collection view
        let widthColl           = collectionView.frame.size.width
        let width               = widthColl - CGFloat(6)
        
        // set width and height for every cell
        return CGSizeMake(width / 2 - 6, 54)
    }
    
    // MARK: - Action Methods
    
    @IBAction func btnAddVisits_Action(sender: AnyObject) {
        let addChurchVC              = storyboard?.instantiateViewControllerWithIdentifier("PAddVisitVC") as! PAddVisitVC
        addChurchVC.currentChurch    = self.currentChurch
        presentViewController(addChurchVC, animated: true, completion: nil)
    }
    
    @IBAction func didSelectNewTab_Action(sender: AnyObject) {
        loadScreenForCurSelectedTab()
    }
    
    @IBAction func btnBack_Action(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func upGestureRecognizer_Action(sender: AnyObject) {
        constraintsOfPlace.constant = -160
        self.imgChurch.hidden = true
        self.viewBackgroundImgChurch.hidden = true
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }) { (finished) -> Void in
        }
    }
    
    @IBAction func downGestureRecognizer_Action(sender: AnyObject) {
        constraintsOfPlace.constant = 0
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }) { (finished) -> Void in
                self.imgChurch.hidden = false
                self.viewBackgroundImgChurch.hidden = false
        }
    }
    
    @IBAction func showSearcBar_Action(sender: AnyObject) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        presentViewController(searchController, animated: true, completion: nil)
    }
    
    // MARK: - PPreachVCDelegate Methods
    
    func didCancelPopover() {
        popover.dismissPopoverAnimated(true)
        loadParams()
    }
    
    func didEditPreach(objectID: String) {
        popover.dismissPopoverAnimated(true)
        
        let editChurchVC         = self.storyboard?.instantiateViewControllerWithIdentifier("PEditVisitVC") as! PEditVisitVC
        editChurchVC.objId       = objectID
        editChurchVC.delegate    = self
        editChurchVC.index       = self.index
        
        presentViewController(editChurchVC, animated: true, completion: nil)
    }
    
    // MARK: - WYPopoverControllerDelegate Methods
    
    func popoverControllerShouldDismissPopover(popoverController: WYPopoverController!) -> Bool {
        return true
    }
    
    // MARK: - PEditVisitVCDelegate Methods
    
    func didCancelEditVC(index: Int) {
        selectItemAtIndex(index)
    }
    
    // MARK: - Location Delegate Methods
    
    // MARK: - UISearchBarDelegate Methods
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
        if self.mapView.annotations.count != 0{
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
        }
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
