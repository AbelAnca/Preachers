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
    case visits, place, details
}

class PChurchVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, WYPopoverControllerDelegate, PPreachVCDelegate, PEditVisitVCDelegate, MKMapViewDelegate, UISearchBarDelegate {
    
    // IBOutlets
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var imgChurch: UIImageView!
    
    // Details View
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblCity: UILabel!
    @IBOutlet var lblPastor: UILabel!
    @IBOutlet var lblAddress: UILabel!
    @IBOutlet var lblNote: UITextView!
    @IBOutlet var lblDistance: UILabel!
    
    // Map View
    @IBOutlet var btnAddVisit: UIButton!
    @IBOutlet var btnShowSearchBar: UIButton!
    @IBOutlet var btnSharePlace: UIButton!
    @IBOutlet var btnAddCancelPlace: UIButton!
    @IBOutlet var btnFindMe: UIButton!
    @IBOutlet var btnFindAddress: UIButton!
    
    @IBOutlet var mapView: MKMapView!
    
    // All Views
    @IBOutlet var viewVisits: UIView!
    @IBOutlet var viewPlace: UIView!
    @IBOutlet var viewDetails: UIView!
    @IBOutlet var viewBackgroundImgChurch: UIView!
    @IBOutlet var viewTutorialVistis: UIView!
    @IBOutlet var viewTutorialPlace: UIView!
    
    // Constraints
    @IBOutlet var constraintsOfPlace: NSLayoutConstraint!
    
    // Segment Control
    @IBOutlet var segmentControl: ADVSegmentedControl!
    
    // For search bar on Map View
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
    
    lazy var popover                = WYPopoverController()
    var isAdd                       = false
    var geoPoint: PFGeoPoint?

    // MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestureRecognizerForMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadParams()
    }
    
    // MARK: - Custom Methods
    
    func setupUI() {
        imgChurch.backgroundColor                   = UIColor.clear
        imgChurch.layer.cornerRadius                = 75
        imgChurch.layer.borderWidth                 = 6
        imgChurch.layer.borderColor                 = UIColor.white.cgColor
        imgChurch.clipsToBounds                     = true
        
        viewBackgroundImgChurch.layer.cornerRadius  = 69
        viewBackgroundImgChurch.clipsToBounds       = true
        
        setupButtons()

        loadScreenForCurSelectedTab()
        
        mapView.showsUserLocation = true
    }
    
    func setupButton(_ button: UIButton) {
        button.layer.cornerRadius        = 22
        button.clipsToBounds             = true
    }
    
    func setupButtons() {
        setupButton(btnShowSearchBar)
        setupButton(btnFindMe)
        setupButton(btnFindAddress)
        setupButton(btnSharePlace)
        setupButton(btnAddCancelPlace)
        
        btnAddCancelPlace.transform          = CGAffineTransform(rotationAngle: CGFloat(-0.25 * M_PI))
    }
    
    
    
    func setupGestureRecognizerForMapView() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(PChurchVC.action(_:)))
        
        gestureRecognizer.minimumPressDuration = 2.0
        
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    func action(_ gestureRecognizer: UIGestureRecognizer) {
        
        if let _ = self.geoPoint {
            let annotationsToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
            mapView.removeAnnotations( annotationsToRemove )
        }
        
        let touchPoint = gestureRecognizer.location(in: self.mapView)
        let newCoordonate: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        
    
        if let objectId = objId {
            let query = PFQuery(className:"Church")
            query.getObjectInBackground(withId: objectId, block: { (object, error) -> Void in
                if error == nil {
                    if let church = object {
                        let newAnotation = MKPointAnnotation()
                        
                        newAnotation.coordinate = newCoordonate
                        
                        if let city = church.object(forKey: "city") as? String {
                            newAnotation.title = city
                        }
                        
                        if let address = church.object(forKey: "address") as? String {
                            newAnotation.subtitle = address
                        }

                        let geoPoint = PFGeoPoint(latitude: newAnotation.coordinate.latitude, longitude: newAnotation.coordinate.longitude)
                        self.geoPoint = geoPoint
                        
                        church["place"]         = geoPoint
                        church.saveInBackground(block: { (success, error) -> Void in
                            if error == nil {
                                if success {
                                    self.mapView.addAnnotation(newAnotation)
                                 }
                            }
                            else {
                                if let error = error {
                                    let errorString         = error.userInfo["error"] as! String
                                    let alert               = Utils.okAlert("Error", message: errorString)
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        })
                    }
                }
            })
        }
    }
    
    fileprivate func loadScreenForCurSelectedTab() {
        if curSelectedTab() == PChurchTab.visits.rawValue {
            viewVisits.isHidden = false
            viewPlace.isHidden = true
            viewDetails.isHidden = true
        }
        else
            if curSelectedTab() == PChurchTab.place.rawValue {
                viewVisits.isHidden = true
                viewPlace.isHidden = true
                viewDetails.isHidden = false
        }
        else
                if curSelectedTab() == PChurchTab.details.rawValue {
                    viewVisits.isHidden = true
                    viewPlace.isHidden = false
                    viewDetails.isHidden = true
        }
    }
    
    fileprivate func curSelectedTab() -> Int {
        return segmentControl.selectedIndex
    }
    
    func loadParams() {
        if let objectId = objId {
            let query = PFQuery(className:"Church")
            query.getObjectInBackground(withId: objectId, block: { (object, error) -> Void in
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

            if let name = church.object(forKey: "name") as? String {
                lblName.text = "\(name)"
            }
            
            if let city = church.object(forKey: "city") as? String {
                lblCity.text = "\(city)"
            }

            if let address = church.object(forKey: "address") as? String {
                lblAddress.text     = "\(address)"
            }
            
            if let distance = church.object(forKey: "distance") as? String {
                lblDistance.text    = "\(distance)"
            }
            
            if let pastor = church.object(forKey: "pastor") as? String {
                lblPastor.text          = "\(pastor)"
            }
            
            if let note = church.object(forKey: "note") as? String {
                lblNote.text        = note
            }
            
            if let place = church.object(forKey: "place") as? PFGeoPoint {
                geoPoint = place
                hideOrShowViewPlace(false)
                findAddress_APICall()
                isAdd = true
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    self.btnAddCancelPlace.transform          = CGAffineTransform(rotationAngle: CGFloat(0 * M_PI))
                    self.btnAddCancelPlace.backgroundColor    = UIColor.red
                    self.hideOrShowViewPlace(false)
                    self.viewTutorialPlace.isHidden             = true
                })
            }
            else {
                findMe_APICall()
            }
            
            if let userPicture = church.object(forKey: "image") as? PFFile {
                userPicture.getDataInBackground(block: { (data, error) -> Void in
                    if error == nil {
                        if let imageData = data {
                            if let image = UIImage(data:imageData) {
                                if image.size == CGSize(width: 200, height: 200) {
                                    //self.imgChurch.backgroundColor  = UIColor.blackColor()
                                    //self.imgChurch.image            = UIImage(named: "churchICO")
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
    
    func hideOrShowTutorialSermon(_ hide: Bool) {
        if hide == true {
            // Hide tutorial sermon
            viewTutorialVistis.isHidden = true
        }
        else {
            // Show tutorial sermon
            viewTutorialVistis.isHidden = false
        }
    }
    
    func hideOrShowViewPlace(_ hide: Bool) {
        if hide == true {
            mapView.isHidden             = true
            btnSharePlace.isHidden       = true
            btnShowSearchBar.isHidden    = true
            btnFindMe.isHidden           = true
            btnFindAddress.isHidden      = true
        }
        else {
            mapView.isHidden             = false
            btnSharePlace.isHidden       = false
            btnShowSearchBar.isHidden    = false
            btnFindMe.isHidden           = false
            btnFindAddress.isHidden      = false
        }
    }
    
    func zoomToRegion(_ latitude: Double, longitude: Double) {
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegionMakeWithDistance(location, 500.0, 700.0)
        mapView.setRegion(region, animated: true)
    }

    // MARK: - API Methods
    
    func findMe_APICall() {
        PFGeoPoint.geoPointForCurrentLocation { (geoPoint, error) -> Void in
            if error == nil {
                if let latitude = geoPoint?.latitude {
                    if let longitude = geoPoint?.longitude {
                        self.zoomToRegion(latitude, longitude: longitude)
                    }
                }
            }
        }
    }
    
    func findAddress_APICall() {
        if let geoPoint = geoPoint {
            let newAnotation = MKPointAnnotation()
            
            newAnotation.coordinate.latitude = geoPoint.latitude
            newAnotation.coordinate.longitude = geoPoint.longitude
            
            if let church = currentChurch {
                if let city = church.object(forKey: "city") as? String {
                    newAnotation.title = city
                }
                
                if let address = church.object(forKey: "address") as? String {
                    newAnotation.subtitle = address
                }
            }
            
            zoomToRegion(geoPoint.latitude, longitude: geoPoint.longitude)
            mapView.addAnnotation(newAnotation)
        }
        else {
            let alert = Utils.okAlert("You don't have the address yet", message: "You have to press more than 2 second on map for create the address.")
            present(alert, animated: false, completion: nil)
        }
    }
    
    func loadPreach() {
        let query = PFQuery(className:"Preach")
        if let church = currentChurch {
            query.whereKey("church", equalTo: church)
            query.findObjectsInBackground { (objects, error) -> Void in
                if error == nil {
                    self.nrVisits         = objects?.count
                    self.arrPreaches      = objects
                    
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let churchs = arrPreaches {
            if churchs.count == 0 {
                hideOrShowTutorialSermon(false)
            }
            else {
                hideOrShowTutorialSermon(true)
            }
            
            return churchs.count
        }
        
        hideOrShowTutorialSermon(true)
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PPreachCell", for: indexPath) as! PPreachCell
        
        if let preaches = arrPreaches {
            let preach              = preaches[indexPath.row]
            let date                = preach.object(forKey: "date") as? String
            let  biblicalText = preach.object(forKey: "biblicalText") as? String
            
            if let date = date {
                cell.lblDate.text       = "\(date)"
            }
            
            if let biblicalText = biblicalText {
                cell.lblBiblicalText.text = "\(biblicalText)"
            }
        }
        return cell

    }
    
    func selectItemAtIndex(_ index: Int) {
        let editChurchVC         = self.storyboard?.instantiateViewController(withIdentifier: "PPreachVC") as! PPreachVC
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
        popoverBackgroundView.outerStrokeColor      = UIColor.clear
        popoverBackgroundView.innerStrokeColor      = UIColor.clear
        
        popover                                     = WYPopoverController(contentViewController: editChurchVC)
        popover.delegate                            = self
        popover.presentPopover(from: self.view.bounds, in: self.view, permittedArrowDirections: .none, animated: true)
    }
    
    // MARK: - UICollectionViewDelegate Methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.index = indexPath.row
        selectItemAtIndex(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        // width of collection view
        let widthColl           = collectionView.frame.size.width
        let width               = widthColl - CGFloat(6)
        
        // set width and height for every cell
        return CGSize(width: width / 2 - 6, height: 54)
    }
    
    // MARK: - Action Methods
    
    @IBAction func btnAddVisits_Action(_ sender: AnyObject) {
        let addChurchVC              = storyboard?.instantiateViewController(withIdentifier: "PAddVisitVC") as! PAddVisitVC
        addChurchVC.currentChurch    = self.currentChurch
        present(addChurchVC, animated: true, completion: nil)
    }
    
    @IBAction func didSelectNewTab_Action(_ sender: AnyObject) {
        loadScreenForCurSelectedTab()
    }
    
    @IBAction func btnBack_Action(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func upGestureRecognizer_Action(_ sender: AnyObject) {
        constraintsOfPlace.constant = -160
        self.imgChurch.isHidden = true
        self.viewBackgroundImgChurch.isHidden = true
        
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: { (finished) -> Void in
        }) 
    }
    
    @IBAction func downGestureRecognizer_Action(_ sender: AnyObject) {
        constraintsOfPlace.constant = 0
        
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: { (finished) -> Void in
                self.imgChurch.isHidden = false
                self.viewBackgroundImgChurch.isHidden = false
        }) 
    }
    
    @IBAction func showSearcBar_Action(_ sender: AnyObject) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    @IBAction func btnFindMe_Action(_ sender: AnyObject) {
        findMe_APICall()
    }
    
    @IBAction func btnFindAddress_Action(_ sender: AnyObject) {
        findAddress_APICall()
    }

    @IBAction func btnAddCancelAddress_Action() {
        if isAdd == true {
            if let _ = geoPoint {
                let alert = UIAlertController(title: "Attention", message: "Are you sure you want to permanently delete this address?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                    self.isAdd = false

                    if let church = self.currentChurch {
                        church.remove(forKey: "place")
                        church.saveInBackground()
                    }
                    
                    self.geoPoint = nil
                    
                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        self.btnAddCancelPlace.transform          = CGAffineTransform(rotationAngle: CGFloat(-0.25 * M_PI))
                        self.btnAddCancelPlace.backgroundColor    = UIColor.preachersBlue()
                        self.hideOrShowViewPlace(true)
                        self.viewTutorialPlace.isHidden             = false
                    })
                    
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                present(alert, animated: true, completion: nil)
            }
            else {
                self.isAdd = false
                
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    self.btnAddCancelPlace.transform          = CGAffineTransform(rotationAngle: CGFloat(-0.25 * M_PI))
                    self.btnAddCancelPlace.backgroundColor    = UIColor.preachersBlue()
                    self.hideOrShowViewPlace(true)
                    self.viewTutorialPlace.isHidden             = false
                })
            }
            
        }
        else {
            let alert = UIAlertController(title: "Attention", message: "You have to press more than 2 second on map for create the address.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
            isAdd = true
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.btnAddCancelPlace.transform          = CGAffineTransform(rotationAngle: CGFloat(0 * M_PI))
                self.btnAddCancelPlace.backgroundColor    = UIColor.red
                self.hideOrShowViewPlace(false)
                self.viewTutorialPlace.isHidden             = true
            })
        }
    }
    
    @IBAction func btnShareAddress_Action(_ sender: AnyObject) {
        if let geoPoint = geoPoint {
            
        }
        else {
            let alert = Utils.okAlert("You don't have the address yet", message: "You have to press more than 2 second on map for create the address.")
            present(alert, animated: false, completion: nil)
        }
    }
    
    // MARK: - PPreachVCDelegate Methods
    
    func didCancelPopover() {
        popover.dismissPopover(animated: true)
        loadParams()
    }
    
    func didEditPreach(_ objectID: String) {
        popover.dismissPopover(animated: true)
        
        let editChurchVC         = self.storyboard?.instantiateViewController(withIdentifier: "PEditVisitVC") as! PEditVisitVC
        editChurchVC.objId       = objectID
        editChurchVC.delegate    = self
        editChurchVC.index       = self.index
        
        present(editChurchVC, animated: true, completion: nil)
    }
    
    // MARK: - WYPopoverControllerDelegate Methods
    
    func popoverControllerShouldDismissPopover(_ popoverController: WYPopoverController!) -> Bool {
        return true
    }
    
    // MARK: - PEditVisitVCDelegate Methods
    
    func didCancelEditVC(_ index: Int) {
        selectItemAtIndex(index)
    }
    
    // MARK: - UISearchBarDelegate Methods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        /*
        if self.mapView.annotations.count != 0 {
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        */
        
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alert = Utils.okAlert("Upss", message: "Place Not Found")
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            //self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
        }
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
