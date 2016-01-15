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

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchControllerDelegate, UIGestureRecognizerDelegate{
    
    // Map
    @IBOutlet weak var mapView: MKMapView!
    var clManager: CLLocationManager!
    
    var internalData: String? // Passed Data from Advanced Search
    
    // SearchController
    var searchController: UISearchController!
    var searchResultsTableView = UITableViewController(style: UITableViewStyle.Grouped)
    var searchStillTyping = false
    var lastSearchString: String = ""
    let maxRowNumberPerSection = (min: 5,max: 10)
    var blurEffectView: UIVisualEffectView?
    
    // Categories for Searchfiltering
    let sectionNames = ["Name", "Adresse", "--Paticipant", "--Notion"]
    var showMoreEntries = [false, false, false, false]
    
    // Array for all Monuments
    var filteredData: [ [(key: String, array: [DMBMonument])] ] = Array(count: 4, repeatedValue: Array<(key: String, array: [DMBMonument])>())
    
    // Values for search History
    var searchHistory: [String] = []
    var showHistory: Bool = true
    
    // Active Threads
    let pendingOperations = PendingOperations()

    // MARK: Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.hidden = true
        
        // Mapstuff
        clManager = initMapLocationManager()
        let anno = DMBDenkmalMapAnnotation(latitude: 53.800337, longitude: 12.178451)
        anno.title = "Denkmal"
        
        mapView.delegate = self
        mapView.addAnnotation(anno)
        
        // Setze Globale Color
        UIButton.appearance().tintColor = self.view.tintColor
        UISwitch.appearance().tintColor = self.view.tintColor
        
        // Setup Search Controller
        setupSearchController()
        setupSearchResultsTable()
        
        updateLocalSearchHistory()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        print(self.internalData)
    }
    
    // MARK: Button Action
    func segueToAdvancedSearchView(sender:UIButton!){
        performSegueWithIdentifier("AdvancedSearchSegue", sender: self)
    }
    
    func showMoreResultsButton(sender:UIButton!){
        showMoreEntries[sender.tag - 1] = !showMoreEntries[sender.tag - 1]
        
        var indexPaths: [NSIndexPath] = []
        for i in 0..<filteredData[sender.tag - 1].count - maxRowNumberPerSection.min {
            indexPaths.append(NSIndexPath(forRow: maxRowNumberPerSection.min + i, inSection: sender.tag))
        }
        
        if showMoreEntries[sender.tag - 1] {
            searchResultsTableView.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        } else {
            searchResultsTableView.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    // MARK: Gesture Handling
    
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AdvancedSearchSegue" {
            //(segue.destinationViewController as! DMBAdvancedSearchViewController).delegate = self
            
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Suche", style: .Plain, target: nil, action: nil)
        }
        
        if segue.identifier == "Detail" {
            // Data Passing for Annotations
            
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Karte", style: .Plain, target: nil, action: nil)
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
    
    // MARK: Search Setup & Config
    
    /// Initialisiert und Configuriert den Search Controller
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
    
    /// Erstellt den TableViewController für die Suchergebnisse und den Verlauf
    /// Und ruft Functionen zum Configureren auf
    func setupSearchResultsTable(){
        searchResultsTableView.tableView.registerClass(DMBSearchResultsHeaderView.self, forHeaderFooterViewReuseIdentifier: NSStringFromClass(DMBSearchResultsHeaderView))
        searchResultsTableView.tableView.registerNib(UINib(nibName: "DMBSearchResultCellProtoype", bundle: nil), forCellReuseIdentifier: "SearchResultsCell")
        
        searchResultsTableView.tableView.dataSource = self
        searchResultsTableView.tableView.delegate = self

        configSearchResultsTableView()
        addGestureRecognitionToTableView()
        addBlurEffectToSearchResultTable()
        
        blurEffectView!.addSubview(searchResultsTableView.tableView)
    }
    
    /// Configuriert die Tabelle mit den Suchergebnissen
    /// Setzt vor allem die Position der TableView unter die Navbar
    func configSearchResultsTableView(){
        // Hide Table at Map
        searchResultsTableView.tableView.hidden = true
        
        // Setzt Position unter die NavBar und Größe an Display angepasst
        let viewFrame = self.view.frame
        let x = self.navigationController?.navigationBar.frame.origin.x
        let y = (self.navigationController?.navigationBar.frame.origin.y)! + (self.navigationController?.navigationBar.frame.height)!
        let originPoint = CGPoint(x: x!, y: y)
        let size = CGSize(width: viewFrame.size.width, height: viewFrame.size.height - y /*- (self.tabBarController?.tabBar.frame.height)!*/)
        let searchResultsTableViewRect = CGRect(origin: originPoint, size: size)
        searchResultsTableView.tableView.frame = searchResultsTableViewRect
        
        // Erlaub Scrollen
        searchResultsTableView.tableView.scrollEnabled = true
        // Versteckt Tastatur wenn gescrollt wird
        searchResultsTableView.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        
    }
    
    func addBlurEffectToSearchResultTable(){
        searchResultsTableView.tableView.backgroundColor?.colorWithAlphaComponent(0.0)
        searchResultsTableView.tableView.opaque = false
        searchResultsTableView.tableView.backgroundColor = UIColor.clearColor()
        
        blurEffectView = UIVisualEffectView(frame: self.view.frame)
        blurEffectView!.effect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        blurEffectView!.hidden = true
        
        self.view.addSubview(blurEffectView!)
    }
    
    /// Fügt Gesten zum TableView hinzu
    func addGestureRecognitionToTableView(){
        let gestureSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "segueToAdvancedSearchView:");
        gestureSwipeRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        gestureSwipeRecognizer.delegate = self
        
        searchResultsTableView.tableView.addGestureRecognizer(gestureSwipeRecognizer)
    }
    
    /// Zeigt TableView an wenn Search beginnt
    func willPresentSearchController(searchController: UISearchController) {
        searchResultsTableView.tableView.hidden = false
        blurEffectView?.hidden = false
    }
    
    /// Versteckt TableView an wenn Search gecancelt wird
    func willDismissSearchController(searchController: UISearchController) {
        searchResultsTableView.tableView.hidden = true
        blurEffectView?.hidden = true
    }
    
    // MARK: Search Result Table
    
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
        if (filteredData.isEmpty || (section != 0 && filteredData[section - 1].isEmpty && !filteredData.isEmpty)) {
            return 0.01
        }
        return 18
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return DMBSearchResultsHeaderView(reuseIdentifier: NSStringFromClass(DMBSearchResultsHeaderView), forMapView: self, forSection: section)
        
        //return DMBTableHeaderView(tableView: tableView, viewForHeaderInSection: section, mapViewSender: self)
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (filteredData.isEmpty || (section == 0 || (section != 0 && filteredData[section - 1].isEmpty) && !filteredData.isEmpty)) {
            return section == 0 ? 4 : 0.01
        }
        return 18
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionNames.count + 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchResultsCell") as! DMBSearchResultsTableViewCell
        
        // Set Labels for Cells
        if(indexPath.section <= sectionNames.count && indexPath.section != 0) {
            if showHistory {
                if (indexPath.section == 1) {
                    cell.titleTextLabel?.text = searchHistory[indexPath.row]
                    cell.subTitleLabel.hidden = true
                }
            } else {
                cell.subTitleLabel.hidden = false
                switch indexPath.section {
                case 1:
                    cell.titleTextLabel?.text = filteredData[indexPath.section - 1][indexPath.row].key
                    let address = filteredData[indexPath.section - 1][indexPath.row].array[0].getAddress()
                    var street = address.getStreet()
                        street = street != nil ? street : ""
                    var number = address.getNr()
                        number = number != nil ? number : ""
                    cell.subTitleLabel?.text = (street! + " " + number!)
                case 2:
                    let address = filteredData[indexPath.section - 1][indexPath.row].array[0].getAddress()
                    var street = address.getStreet()
                        street = street != nil ? street : ""
                    var number = address.getNr()
                        number = number != nil ? number : ""
                    cell.titleTextLabel?.text = street! + " " + number!
                
                    cell.subTitleLabel?.text = filteredData[indexPath.section - 1][indexPath.row].key
                case 3:
                    cell.titleTextLabel?.text = filteredData[indexPath.section - 1][indexPath.row].key
//                case 4: cell.titleTextLabel?.text = filteredData[indexPath.section - 1][indexPath.row].getName()
                default: break
                }
                
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if showHistory {
            self.searchController.searchBar.text = searchHistory[indexPath.row]
        } else {
            let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as! DMBSearchResultsTableViewCell
            DMBModel.sharedInstance.setHistoryEntry(cell.titleTextLabel.text!)
            updateLocalSearchHistory()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showHistory && section == 1 {
            return searchHistory.count
        } else if(section - 1 <= sectionNames.count && section != 0 && !filteredData.isEmpty) {
            var numRows = filteredData[section - 1].count
            if !showMoreEntries[section - 1] {
                numRows = filteredData[section - 1].count <= maxRowNumberPerSection.min ? filteredData[section - 1].count : maxRowNumberPerSection.min
            }
            return numRows
        } else { return 0 }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return showHistory ? 38 : 50
    }

    
    // MARK: Search Updater
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        
        if lastSearchString != searchText {
            lastSearchString = searchText!
            
            for i in 0..<filteredData.count {
                filteredData[i].removeAll()
            }
            
            startSearchForMonument(searchText!)
            
            // Verlauf ausblenden wenn tippen beginnt
            if searchStillTyping == false && searchText?.isEmpty == false {
                resetShowMoreButton()
                searchResultsTableView.tableView.reloadData()
                searchStillTyping = true
            }
        }
    }
    
    /// Updated das Locale Array mit Suchverlauf mit der Datenbank
    func updateLocalSearchHistory(){
        searchHistory.removeAll()
        DMBModel.sharedInstance.getHistory().forEach({entry in
            searchHistory.append(entry.getSearchString()!)
        })
        searchHistory = searchHistory.reverse()
    }
    
    /// Reset die Mehr Anzeigen Buttons bei neuladen der Suchergebnisse
    func resetShowMoreButton(){
        for i in 0..<showMoreEntries.count {
            showMoreEntries[i] = false
        }
    }
    
    // MARK: Multi-Threading - NSOperationQueue
    
    func startSearchForMonument(searchText: String){
        
        var threadNumber = 0
        
        // Wenn bereits existiert dann Canceln bis einer frei ist
        while let searchOperation = pendingOperations.searchsInProgress[threadNumber] {
            searchOperation.cancel()
            
            if threadNumber == 10 {
                threadNumber = 0
                break;
            } else { threadNumber++ }
        }
        
        let search = SearchMonument(searchText: searchText, minMaxResultNumber: maxRowNumberPerSection)
        
        search.completionBlock = {
            if search.cancelled {
                self.pendingOperations.searchsInProgress.removeValueForKey(threadNumber)
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.pendingOperations.searchsInProgress.removeValueForKey(threadNumber)
                
                self.filteredData = search.filteredData
                self.resetShowMoreButton()
                self.searchResultsTableView.tableView.reloadData()
                self.searchStillTyping = false
                
            })
        }
        
        pendingOperations.searchsInProgress[threadNumber] = search
        
        if searchText.isEmpty == false {
            pendingOperations.searchQueue.addOperation(search)
            showHistory = false
        } else { // wenn Searchfield leer dann alle Threads killen z.b. wenn man mit Backspace löscht
            pendingOperations.searchsInProgress.forEach({s in s.1.cancel() })
            
            showHistory = true
            searchStillTyping = false
            resetShowMoreButton()
            searchResultsTableView.tableView.reloadData()
        }
        
    }
}

extension MapViewController: DMBAdvancedSearchDelegate {
    func sendDataBack(data: String) {
        self.internalData = data
    }
}