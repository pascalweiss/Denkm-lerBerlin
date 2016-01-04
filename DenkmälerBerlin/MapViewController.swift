//
//  MapController.swift
//  DenkmälerBerlin
//
//  Created by Max on 30.10.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchControllerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    var clManager: CLLocationManager!
    
    let sectionNames = ["Name"]
    
    var monumentString: [String] = []
    var monuments: [DMBMonument] = []
    
    var searchHistory: [String] = ["Schloss", "Kirche"]
    
    var filteredData = Array(count: 5, repeatedValue: Array(count: 0, repeatedValue: String()))
    var searchController: UISearchController!
    
    var searchResultsTableView = UITableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DMBModel.sharedInstance
        monuments = DMBModel.sharedInstance.getAllMonuments()
        
        clManager = initMapLocationManager()
        let anno = DenkmalMapAnnotation(latitude: 53.800337, longitude: 12.178451)
        anno.title = "Denkmal"
        
        mapView.delegate = self
        
        mapView.addAnnotation(anno)
        
        setupSearchController()
        setupSearchResultsTable()
        
        
        
    }
    
    func initMapLocationManager() -> CLLocationManager {
        
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
//      Update User Position
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        return manager
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
        manager.stopUpdatingLocation()
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let identifier = "DenkmalAnnotation"
        
        if annotation.isKindOfClass(DenkmalMapAnnotation.self) {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            
            if annotationView == nil {
                
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
                
                
                let btn = UIButton(type: .DetailDisclosure)
                annotationView!.rightCalloutAccessoryView = btn
            } else {
                
                annotationView!.annotation = annotation
            }
            
            return annotationView
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            performSegueWithIdentifier("Detail", sender: self)
        }
    }
    
    // MARK: Search
    
    func setupSearchController(){
        
        //filteredData = data
        
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        
        searchController.dimsBackgroundDuringPresentation = false
        
        // Serach Bar in Navigation
        searchController.searchBar.sizeToFit()
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        
        // Sets this view controller as presenting view controller for the search interface
        definesPresentationContext = true
        
    }
    
    func setupSearchResultsTable(){
        searchResultsTableView.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "SearchTabelCell")
        
        searchResultsTableView.tableView.dataSource = self
        searchResultsTableView.tableView.delegate = self
        
        //searchResultsTableView.automaticallyAdjustsScrollViewInsets = true

        configSearchResultsTableView()
        
        
        self.view.addSubview(searchResultsTableView.tableView)
    }
    
    func configSearchResultsTableView(){
        // Hide Table at Map
        searchResultsTableView.tableView.hidden = true
        
        // Set Size and Position of Map
        let viewFrame = self.view.frame
        let x = self.navigationController?.navigationBar.frame.origin.x
        let y = (self.navigationController?.navigationBar.frame.origin.y)! + (self.navigationController?.navigationBar.frame.height)!
        let originPoint = CGPoint(x: x!, y: y)
        let searchResultsTableViewRect = CGRect(origin: originPoint, size: viewFrame.size)
        searchResultsTableView.tableView.frame = searchResultsTableViewRect
        
        // Color and Transparency
        searchResultsTableView.tableView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        searchResultsTableView.tableView.hidden = false
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        searchResultsTableView.tableView.hidden = true
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0 || filteredData[section].isEmpty) {
            return nil
        }
        return sectionNames[section - 1]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // Text Color for Header
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.whiteColor()
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchTabelCell")! as UITableViewCell
        
        switch(indexPath.section){
        case 0: cell.textLabel?.text = filteredData[0][indexPath.row]
        case 1: cell.textLabel?.text = filteredData[1][indexPath.row]
        default: break
        }
        
        // Color and Transparency Settings
        cell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        cell.textLabel?.textColor = UIColor.whiteColor()
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section){
        case 0: return filteredData[0].count
        case 1: return filteredData[1].count
        default: return 0
        }
        
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        
        for i in 0..<filteredData.count {
            filteredData[i].removeAll()
        }
        
        if searchText?.isEmpty == false {
            var filteredMonuments: [[DMBMonument]] = []
            
            filteredMonuments.append(monuments.filter(){
                return $0.getName()!.rangeOfString(searchText!, options: .CaseInsensitiveSearch) != nil
            })
            
            for i in 0..<filteredMonuments.count {
                for j in 0..<filteredMonuments[i].count {
                    switch (i + 1) {
                    case 1: filteredData[i].append(filteredMonuments[i][j].getName()!)
                    default: break
                    }
                    
                }
            }
        } else {
            filteredData[0] = searchHistory
        }
        
        searchResultsTableView.tableView.reloadData()
    }
}