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

// MARK: - Main MapViewController Class
class MapViewController: UIViewController, UIGestureRecognizerDelegate{
    
    // MARK: Table
    var searchResultsTableView = UITableViewController(style: UITableViewStyle.Grouped)
    let maxRowNumberPerSection = (min: 5,max: 10)
    
    // Categories for Searchfiltering
    let sectionNames = ["Name", "Adresse", "Beteiligte", "Gebäudetyp"]
    var showMoreEntries = [false, false, false, false]
    
    // Values for search History
    var searchHistory: [String] = []
    var showHistory: Bool = true
    
    // Default View
    var defaultView: UIView?
    var showDefaultLabels = (history: UILabel(), noMatch: UILabel(), activity: UIActivityIndicatorView())
    
    // MARK: Blur Effect
    var blurEffectView: UIVisualEffectView?
    
    // MARK: SearchController
    var searchController: UISearchController!
    var searchStillTyping = false
    var lastSearchString: String = ""
    var searchItemDisplayOnMap = false
    
    // Array for all Monuments
    var filteredData: [ [(key: String, array: [DMBMonument])] ] = Array(count: 4, repeatedValue: Array<(key: String, array: [DMBMonument])>())

    
    // MARK: Map
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .Standard
            mapView.showsPointsOfInterest = false
            mapView.delegate = self
        }
    }
    var clManager: CLLocationManager!
    
    
    // MARK: Data Passing
    var internalFilter: DMBFilter? // Passed Data from Advanced Search
    
    // MARK: Active Threads
    let pendingOperations = PendingOperations()
    let pendingDrawOps = PendingDrawOperations()
    
    var activitySymbol: UIActivityIndicatorView?
    
    // Annotations variables
    let clusterManager = FBClusteringManager()
    var annotationsToDraw: [DMBDenkmalMapAnnotation] = [] {
        didSet {
            drawClusters()
        }
    }
    var visibleMapRect: MKMapRect?
    var centerCoord: CLLocationCoordinate2D?
    var neCoord: CLLocationCoordinate2D?
    var swCoord: CLLocationCoordinate2D?
    var latitudeDelta: Double?
    var longitudeDelta: Double?
    var monumentToSend: DMBMonument?

    // MARK: Life-Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.hidden = true
        addToolBarToBottom()
        
        
        clManager = initMapLocationManager()
        
        // Setze Globale Color
        UIButton.appearance().tintColor = self.view.tintColor
        UISwitch.appearance().tintColor = self.view.tintColor
        
        // Setup Search Controller
        setupSearchController()
        setupSearchResultsTable()
        
        
        
        updateLocalSearchHistory()
    }
    
    override func viewWillAppear(animated: Bool) {
        let search = self.searchController.searchBar.text
        self.searchController.searchBar.text = ""
        self.searchController.searchBar.text = search
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
    
    func resetSearch(sender:UIBarButtonItem!){
        searchItemDisplayOnMap = false
        getMonumentsForVisibleMapArea()
        
    }
    
    /// Reset die Mehr Anzeigen Buttons bei neuladen der Suchergebnisse
    func resetShowMoreButton(){
        for i in 0..<showMoreEntries.count {
            showMoreEntries[i] = false
        }
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AdvancedSearchSegue" {
            (segue.destinationViewController as! DMBAdvancedSearchViewController).delegate = self
            
            let destinationVC = segue.destinationViewController as! DMBAdvancedSearchViewController
            
            if internalFilter != nil {
                destinationVC.filter = internalFilter!
            }
            
            
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Suche", style: .Plain, target: nil, action: nil)
        }
        
        if segue.identifier == "Detail" {
            // Data Passing for Annotations
            let destinationVC = segue.destinationViewController as! DMBDetailsTableViewController
            
            destinationVC.monument = monumentToSend
            
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Karte", style: .Plain, target: nil, action: nil)
        }
    }
    
    // MARK: Toolbar
    func addToolBarToBottom(){
        let toolbar = UIToolbar()
        toolbar.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)
        toolbar.sizeToFit()
        
        let trackingItem = MKUserTrackingBarButtonItem(mapView: mapView)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        activitySymbol = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activitySymbol!.startAnimating()
        
        let activityItem = UIBarButtonItem(customView: activitySymbol!)
        
        
        let resetItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "resetSearch:")
        
        toolbar.setItems([trackingItem,flexSpace,activityItem,flexSpace,resetItem], animated: true)
        //toolbar.backgroundColor = UIColor.redColor()
        self.view.addSubview(toolbar)
    }
    
    // MARK: Motion Gestures
    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            DMBModel.sharedInstance.deleteHistory()
            self.updateLocalSearchHistory()
            
            self.searchResultsTableView.tableView.reloadData()
        }
    }
    
}

// MARK: - Data Passing
extension MapViewController: DMBAdvancedSearchDelegate {
    func sendDataBack(data: DMBFilter) {
        self.internalFilter = data
    }
}

// MARK: - TableView Controller
extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Setup
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
        
        setupDefaultView()
        blurEffectView!.addSubview(searchResultsTableView.tableView)
    }
    
    // MARK: Config
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
    
    func setupDefaultView(){
        
        // Setzt Position unter die NavBar und Größe an Display angepasst
        let viewFrame = self.view.frame
        let x = self.navigationController?.navigationBar.frame.origin.x
        let y = (self.navigationController?.navigationBar.frame.origin.y)! + (self.navigationController?.navigationBar.frame.height)!
        let originPoint = CGPoint(x: x!, y: y)
        let size = CGSize(width: viewFrame.size.width, height: viewFrame.size.height - y /*- (self.tabBarController?.tabBar.frame.height)!*/)
        
        let searchResultsTableViewRect = CGRect(origin: originPoint, size: size)
        
        defaultView = UIView(frame: searchResultsTableViewRect)
        
        
        showDefaultLabels.history = UILabel(frame: CGRect(x: 0, y: viewFrame.size.height * 0.1, width: viewFrame.size.width, height: 18))
        showDefaultLabels.history.text = "Verlauf leer"
        showDefaultLabels.history.textAlignment = NSTextAlignment.Center
        showDefaultLabels.history.textColor = UIColor.lightGrayColor()
        showDefaultLabels.history.hidden = true
        
        showDefaultLabels.noMatch = UILabel(frame: CGRect(x: 0, y: viewFrame.size.height * 0.1, width: viewFrame.size.width, height: 18))
        showDefaultLabels.noMatch.text = "Kein Treffer"
        showDefaultLabels.noMatch.textAlignment = NSTextAlignment.Center
        showDefaultLabels.noMatch.textColor = UIColor.lightGrayColor()
        showDefaultLabels.noMatch.hidden = true
        
        showDefaultLabels.activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        showDefaultLabels.activity.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        showDefaultLabels.activity.center = CGPoint(x: viewFrame.size.width / 2, y: viewFrame.size.height * 0.15)
        
        defaultView!.addSubview(showDefaultLabels.history)
        defaultView!.addSubview(showDefaultLabels.noMatch)
        defaultView?.addSubview(showDefaultLabels.activity)
        blurEffectView!.addSubview(defaultView!)
    }
    
    // MARK: Background Effect
    func addBlurEffectToSearchResultTable(){
        searchResultsTableView.tableView.backgroundColor?.colorWithAlphaComponent(0.0)
        searchResultsTableView.tableView.opaque = false
        searchResultsTableView.tableView.backgroundColor = UIColor.clearColor()
        
        blurEffectView = UIVisualEffectView(frame: self.view.frame)
        blurEffectView!.effect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        blurEffectView!.hidden = true
        
        self.view.addSubview(blurEffectView!)
    }
    
    // MARK: Gestures
    /// Fügt Gesten zum TableView hinzu
    func addGestureRecognitionToTableView(){
        let gestureSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "segueToAdvancedSearchView:");
        gestureSwipeRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        gestureSwipeRecognizer.delegate = self
        
        searchResultsTableView.tableView.addGestureRecognizer(gestureSwipeRecognizer)
    }
    
    // MARK: Table General
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionNames.count + 1
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
    
    // MARK: Table Header
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
        return 22
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return DMBSearchResultsHeaderView(reuseIdentifier: NSStringFromClass(DMBSearchResultsHeaderView), forMapView: self, forSection: section)
        
        //return DMBTableHeaderView(tableView: tableView, viewForHeaderInSection: section, mapViewSender: self)
    }
    
    // MARK: Table Footer
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (filteredData.isEmpty || (section == 0 || (section != 0 && filteredData[section - 1].isEmpty) && !filteredData.isEmpty)) {
            return section == 0 ? 4 : 0.01
        }
        return 18
    }
    
    // MARK: Table Cells / Rows
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return showHistory ? 38 : 50
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
                case 3...4:
                    cell.titleTextLabel?.text = filteredData[indexPath.section - 1][indexPath.row].key
                    var subText: String = ""
                    for var i = 0; i < filteredData[indexPath.section - 1][indexPath.row].array.count && i < 5; i++ {
                        subText.appendContentsOf(filteredData[indexPath.section - 1][indexPath.row].array[i].getName()! + ", ")
                    }
                    
                    cell.subTitleLabel.text = subText
                    
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
            
            
            var selected: [DMBDenkmalMapAnnotation] = []
            for var i = 0; i < filteredData[indexPath.section - 1][indexPath.row].array.count; i++ {
                let mon = filteredData[indexPath.section - 1][indexPath.row].array[i]
                
                let address = mon.getAddress()
                let title = mon.getName()!
                let type = mon.getType()!.getName()!
                
                var long = address.getLong()
                long = long != nil ? long : 0
                var lat = address.getLat()
                lat = lat != nil ? lat : 0
                let anno = DMBDenkmalMapAnnotation(title: title, type: type, coordinate: CLLocationCoordinate2D(latitude: lat!, longitude: long!), monument: mon)
                
                var street = address.getStreet()
                street = street != nil ? street : ""
                var number = address.getNr()
                number = number != nil ? number : ""
                anno.subtitle = street! + " " + number!
                
                if long != 0 && lat != 0 {
                    selected.append(anno)
                }
            }
            
            annotationsToDraw = selected
            searchItemDisplayOnMap = true
            searchController.active = false
            
            self.mapView.showAnnotations(annotationsToDraw, animated: true)
        }
    }

}

// MARK: - Search Controller
extension MapViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    
    // MARK: Init & Config
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
    
    
    // MARK: SC Life-Cycle
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
        
        showDefaultLabels.noMatch.hidden = true
        showDefaultLabels.history.hidden = searchHistory.count == 0 ? false : true
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
        
        let search = SearchMonument(searchText: searchText, minMaxResultNumber: maxRowNumberPerSection, filterSearch: internalFilter)
        
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
                
                var empty = true
                for entry in self.filteredData {
                    if entry.count != 0 {
                        empty = false
                    }
                }
                
                
                self.showDefaultLabels.noMatch.hidden = empty ? false : true
                self.showDefaultLabels.activity.stopAnimating()
            })
        }
        
        pendingOperations.searchsInProgress[threadNumber] = search
        
        if searchText.isEmpty == false {
            self.showDefaultLabels.history.hidden = true
            self.showDefaultLabels.activity.startAnimating()
            pendingOperations.searchQueue.addOperation(search)
            showHistory = false
        } else { // wenn Searchfield leer dann alle Threads killen z.b. wenn man mit Backspace löscht
            self.showDefaultLabels.activity.stopAnimating()
            pendingOperations.searchsInProgress.forEach({s in s.1.cancel() })
            
            showHistory = true
            searchStillTyping = false
            resetShowMoreButton()
            updateLocalSearchHistory()
            searchResultsTableView.tableView.reloadData()
        }
        
    }

}

// MARK: - Map
extension MapViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    
    // MARK: Init
    func initMapLocationManager() -> CLLocationManager {
        
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        //      Update User Position
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        return manager
    }
    
    // MARK: CoreLocation
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
        manager.stopUpdatingLocation()
    }
    
    /** Funktionalitaet fuer den calloutAccessorys
     **/
    
    // MARK: MapView
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let _ = view.annotation as? DMBDenkmalMapAnnotation {
            if control == view.rightCalloutAccessoryView {
                monumentToSend = (view.annotation as! DMBDenkmalMapAnnotation).monument
                
                performSegueWithIdentifier("Detail", sender: self)
            }
            if control == view.leftCalloutAccessoryView {
                let location = view.annotation as! DMBDenkmalMapAnnotation
                let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                location.landmarkToMKMapItem().openInMapsWithLaunchOptions(launchOptions)
            }
        }
        
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        setUpVisibleMapRegionParams()
        drawClusters()
        if !searchItemDisplayOnMap {
            getMonumentsForVisibleMapArea()
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var reuseId = ""
        if let _ = annotation as? DenkmalAnnotationCluster {
            reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            clusterView = DenkmalAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId)
            let tapGesture = UITapGestureRecognizer(target: self, action: "zoominOnCluster:")
            tapGesture.numberOfTapsRequired = 2
            clusterView?.addGestureRecognizer(tapGesture)
            clusterView?.userInteractionEnabled
            return clusterView
        } else {
            if let annotation = annotation as? DMBDenkmalMapAnnotation {
                let reuseId = "DenkmalAnnotation"
                let annotationView: MKAnnotationView
                
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                annotationView.canShowCallout = true
                annotationView.calloutOffset = CGPoint(x: -5, y: -5)
                annotationView.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
                
                let button = UIButton(type: .System) as UIButton
                button.setTitle("↪︎", forState: .Normal)
                button.frame = CGRect(x: 30,y: 30,width: 30,height: 30)
                
                annotationView.leftCalloutAccessoryView = button
                
                switch annotation.type! {
                case "Gesamtanlage" :
                    annotationView.image = UIImage(named: "redMarker.png")
                    break
                case "Bodendenkmal":
                    annotationView.image = UIImage(named: "oliveMarker.png")
                    break
                case "Baudenkmal":
                    annotationView.image = UIImage(named: "blueMarker.png")
                    break
                case "Gartendenkmal":
                    annotationView.image = UIImage(named: "lightgreenMarker.png")
                    break
                case "Ensemble":
                    annotationView.image = UIImage(named: "orangeMarker.png")
                    break
                case "Ensembleteil":
                    annotationView.image = UIImage(named: "yellowMarker.png")
                    break
                default:
                    break
                }
                annotationView.frame = CGRectMake(0, 0, 35, 35)
                return annotationView
            }
            return nil
        }
    }
    
    func zoominOnCluster(gesture: UIGestureRecognizer) {
        if let clusterView = gesture.view as? DenkmalAnnotationClusterView {
            if let cluster = clusterView.annotation as? DenkmalAnnotationCluster {
                mapView.setRegion(cluster.getMKCoordinateRegionForCluster(), animated: true)
            }
            
        }
        
    }
    
    // MARK: Helpermethods
    
    func setUpVisibleMapRegionParams() {
        visibleMapRect = mapView.visibleMapRect
        centerCoord = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMidX(visibleMapRect!), MKMapRectGetMidY(visibleMapRect!)))
        neCoord = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(visibleMapRect!), visibleMapRect!.origin.y))
        swCoord = MKCoordinateForMapPoint(MKMapPointMake(visibleMapRect!.origin.x, MKMapRectGetMaxY(visibleMapRect!)))
        latitudeDelta = abs((neCoord?.latitude)! - (swCoord?.latitude)!) / 2.0
        longitudeDelta = abs((neCoord?.longitude)! - (swCoord?.longitude)!) / 2.0
    }
    
    func drawClusters() {
        
        NSOperationQueue().addOperationWithBlock({
            self.clusterManager.tree = nil
            self.clusterManager.addAnnotations(self.annotationsToDraw)
            // TODO: print("Annos to draw: \(self.annotationsToDraw.count)")
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
            let scale:Double = mapBoundsWidth / mapRectWidth
            let annotationArray = self.clusterManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale:scale)
            self.clusterManager.displayAnnotations(annotationArray, onMapView:self.mapView)
        })
    }
    
    // MARK: Threaded Get Monuments
    func getMonumentsForVisibleMapArea(){
        
        if pendingDrawOps.drawsInProgress.count > 0 {
            pendingDrawOps.drawQueue.cancelAllOperations()
            // TODO: print("Pending operation was cancelled")
        }
        setUpVisibleMapRegionParams()
        let area = MKCoordinateRegion.init(
            center: CLLocationCoordinate2D.init(latitude: centerCoord!.latitude, longitude: centerCoord!.longitude),
            span: MKCoordinateSpan.init(latitudeDelta: latitudeDelta!, longitudeDelta: longitudeDelta!))
        
        let getOperation = GetMonumentsForArea(mapArea: area)
        
        getOperation.completionBlock = {
            if getOperation.cancelled {
                self.pendingDrawOps.drawsInProgress.removeAll()
                //print("2Pending operation was cancelled")
                return
            }
            
            self.activitySymbol?.stopAnimating()
            self.pendingDrawOps.drawsInProgress.removeAll()
            //print("found annos: \(getOperation.annotationsFromDb.count)")
            self.annotationsToDraw = getOperation.annotationsFromDb
            
        }
        
        activitySymbol?.startAnimating()
        pendingDrawOps.drawsInProgress.append(getOperation)
        pendingDrawOps.drawQueue.addOperation(getOperation)
    }
}