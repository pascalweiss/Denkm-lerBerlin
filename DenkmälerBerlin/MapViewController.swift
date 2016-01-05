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
    
    var internalData: String? // Passed Data from Advanced Search
    
    
    var searchController: UISearchController!
    var searchResultsTableView = UITableViewController(style: UITableViewStyle.Grouped)
    
    // Categories for Searchfiltering
    let sectionNames = ["Name", "Bezirk"]
    
    // Array for all Monuments
    var monuments: [DMBMonument] = []
    var filteredData = Array(count: 5, repeatedValue: Array<DMBMonument>())
    
    // Values for search History
    var searchHistory: [String] = ["Schloss", "Kirche"]
    var showHistory: Bool = true

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load Database
        //DMBModel.sharedInstance
        //monuments = DMBModel.sharedInstance.getAllMonuments()
        
        // Mapstuff
        clManager = initMapLocationManager()
        let anno = DMBDenkmalMapAnnotation(latitude: 53.800337, longitude: 12.178451)
        anno.title = "Denkmal"
        
        mapView.delegate = self
        mapView.addAnnotation(anno)
        
        // Setup Search Controller
        setupSearchController()
        setupSearchResultsTable()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        print(self.internalData)
    }
    
    // MARK: Button Action
    func segueToAdvancedSearchView(sender:UIButton!){
        performSegueWithIdentifier("AdvancedSearchSegue", sender: self)
    }
    
    func showMoreResultsButton(sender:UIButton!){
        print(sender.tag)
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AdvancedSearchSegue" {
            //(segue.destinationViewController as! DMBAdvancedSearchViewController).delegate = self
        }
        
        if segue.identifier == "Detail" {
            // Data Passing for Annotations
        }
    }
    
    // MARK: Map
    
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
        
        if annotation.isKindOfClass(DMBDenkmalMapAnnotation.self) {
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
        
        // Segue for Annotaion
        if control == view.rightCalloutAccessoryView {
            performSegueWithIdentifier("Detail", sender: self)
        }
    }
    
    // MARK: Search
    
    func setupSearchController(){
        
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
        
        searchResultsTableView.tableView.scrollEnabled = true
        
        // Color and Transparency
        //searchResultsTableView.tableView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        searchResultsTableView.tableView.hidden = false
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        searchResultsTableView.tableView.hidden = true
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section != 0) {
            if (showHistory || filteredData[section - 1].isEmpty) {
                return nil
            }
            return sectionNames[section - 1]
        }
        return nil
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section != 0 && filteredData[section - 1].isEmpty) {
            return 0.01
        }
        return 18
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return DMBTableHeaderView(tableView: tableView, viewForHeaderInSection: section, mapViewSender: self)
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == 0 || (section != 0 && filteredData[section - 1].isEmpty)) {
            return section == 0 ? 4 : 0.01
        }
        return 18
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionNames.count + 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchTabelCell")! as UITableViewCell
        
        // Set Labels for Cells
        if(indexPath.section <= sectionNames.count && indexPath.section != 0) {
            if showHistory {
                if (indexPath.section == 1) {
                    cell.textLabel?.text = searchHistory[indexPath.row]
                }
            } else {
                cell.textLabel?.text = filteredData[indexPath.section - 1][indexPath.row].getName()
            }
        }
        
        // Color and Transparency Settings
        //cell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        //cell.textLabel?.textColor = UIColor.whiteColor()
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showHistory && section == 1 {
            return searchHistory.count
        } else if(section - 1 <= sectionNames.count && section != 0) {
                return filteredData[section - 1].count
        } else { return 0 }
    }

    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        
        sleep(1)
        
        for i in 0..<filteredData.count {
            filteredData[i].removeAll()
        }
        
        if searchText?.isEmpty == false {
            
            var filteredMonuments: [String:[(Double,DMBMonument)]] = DMBModel.sharedInstance.searchMonuments(searchText!)
            
            
            // Filter by Name
            for var i = 0; i < filteredMonuments[DMBSearchKey.byName]!.count && i < 5; i++ {
                filteredData.append([])
                filteredData[0].append(filteredMonuments[DMBSearchKey.byName]![i].1)
            }
            
            for var i = 0; i < filteredMonuments[DMBSearchKey.byName]!.count && i < 5; i++ {
                filteredData.append([])
                filteredData[1].append(filteredMonuments[DMBSearchKey.byName]![i].1)
            }
            
            showHistory = false
        } else {
            // Displays Default Search History
            //filteredData[0] = searchHistory
            showHistory = true
        }
        
        searchResultsTableView.tableView.reloadData()
    }
}

extension MapViewController: DMBAdvancedSearchDelegate {
    func sendDataBack(data: String) {
        self.internalData = data
    }
}