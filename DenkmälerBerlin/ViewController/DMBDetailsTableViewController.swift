//
//  DetailsTableViewController.swift
//  DenkmälerBerlin
//
//  Created by Max on 10.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import UIKit
import MapKit

class DMBDetailsTableViewController: UITableViewController, MKMapViewDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .Standard
            mapView.showsPointsOfInterest = false
            mapView.userInteractionEnabled = false
            mapView.delegate = self
        }
    }
    
    var monument: DMBMonument! = DMBModel.sharedInstance.getAllMonuments()[12];
    var monumentData: Dictionary<String, String>! = Dictionary<String, String>();
    var printOrder: [String] = ["Adresse", "Bauzeit", "Beschreibung"];
    var descriptionPosition = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        //mapView.userInteractionEnabled = false;
        mapView.zoomEnabled = false;
        tableView.bounces = false;
        // construct property array from monument properties
        
        // set Description Position
        if (printOrder.indexOf("Beschreibung") != nil) {
            descriptionPosition = printOrder.indexOf("Beschreibung")!;
        }
    
        // Name
        let monName = self.monument.getName()
        if (monName != nil){
            self.monumentData.updateValue(monName!, forKey: "Name");
            
        }
        
        // Description
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let monDescription = self.monument.getDescription()
            if (monDescription != nil){
                self.monumentData.updateValue(monDescription!, forKey: "Beschreibung");
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
        })
        
        // Date
        let monCreationPeriod = self.monument.getCreationPeriod()
        if (monCreationPeriod != nil){
            var dateString: String = "";
            let dateFormater = NSDateFormatter.init();
            dateFormater.timeZone = NSTimeZone(name: "Europe/Berlin");
            dateFormater.locale = NSLocale(localeIdentifier: "de-DE");
            dateFormater.dateFormat = "MMMM yyyy";
            if (monCreationPeriod?.getFrom() != nil){
                dateString = dateFormater.stringFromDate(monCreationPeriod!.getFrom()!) + " - ";
            }
            if (monCreationPeriod?.getTo() != nil) {
                dateString += dateFormater.stringFromDate(monCreationPeriod!.getTo()!);
            }
            self.monumentData.updateValue(dateString, forKey: "Bauzeit");
            
        }
        
        // Address
        let monAddress = self.monument.getAddress()
        let monStreet = monAddress.getStreet()
        let monNumber = monAddress.getNr()
        var addressString: String = "";
        if (monStreet != nil){
            addressString = monStreet! + " ";
        }
        if (monNumber != nil) {
            addressString += monNumber!;
        }
        if (addressString != ""){
            self.monumentData.updateValue(addressString, forKey: "Adresse");
        }
        
        
        // MAP
        // show object on map
        let lat = self.monument.getAddress().getLat();
        let long = self.monument.getAddress().getLong();
        
        if (lat != nil && long != nil) {
            // center map on monument coordinates
            
            let monumentCoordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!);
            
            // add Annotation
            let anno = DMBDenkmalMapAnnotation.init(title: self.monument.getName()!, type: (self.monument.getType()?.getName()!)!, coordinate: monumentCoordinate, monument: self.monument)
            
            
            let region = MKCoordinateRegion(center: monumentCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            self.mapView.setRegion(region, animated: true)
            
            self.mapView.addAnnotation(anno);
            
            //mapView.centerCoordinate = monumentCoordinate;
            self.mapView.showAnnotations([anno], animated: true);
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // Picture for Header
            let picURL: NSURL?;
            //        picURL = NSURL.init(string: "https://thumbs.dreamstime.com/z/berlin-above-aerial-view-center-germany-35821603.jpg");
            let strURL = self.monument!.getPicUrl()
            picURL = strURL.count == 0 ? nil : NSURL.init(string: strURL[0].getURL()!);
            if (picURL != nil){
                // get picture from URL
                let imageData: NSData? = NSData.init(contentsOfURL: picURL!)!;
                if (imageData != nil){
                    let image: UIImage? = UIImage.init(data: imageData!);
                    if (image != nil){
                        // make image view
                        let imageView = UIImageView.init(frame: CGRect(x: self.mapView.frame.origin.x, y: self.mapView.frame.origin.y, width: UIScreen.mainScreen().bounds.width, height: self.mapView.frame.height));
                        imageView.image = image;
                        imageView.contentMode = .ScaleAspectFill;
                        imageView.clipsToBounds = true;
                        // add image view to superview
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.view.addSubview(imageView);
                        });
                        
                    }
                }
            }
            
        });
        
        
        // DONE
        // navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return printOrder.count;
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return monumentData["Name"];
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row != self.descriptionPosition){
            return 44;
        } else {
            if (self.printOrder.count < 2){
                return 352;
            } else {
                return 220;
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row != self.descriptionPosition){
            let cell = tableView.dequeueReusableCellWithIdentifier("contentValueCell", forIndexPath: indexPath) as! DMBDetailsTableViewCell;
            
            let currentKey = printOrder[indexPath.row];
            cell.labelPropertyHeading.text = currentKey;
            let value = self.monumentData[currentKey];
            
            if (value != nil){
                cell.labelPropertyValue.text = value;
            }
            
            return cell;
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("descriptionTextCell", forIndexPath: indexPath) as! DMBDetailsTextTableViewCell;
            cell.passControllerReference(self);
            
            let currentKey = printOrder[indexPath.row];
            cell.labelDescriptionHeading.text = currentKey;
            let fullText: String? = monumentData.count == 0 ? "" : monumentData[currentKey]; //"Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."; //
            
            if (fullText != nil) {
                // truncate text if neccessary
                var charactersToDisplay: Int;
                
                if (self.printOrder.count < 2){
                    charactersToDisplay = 900;
                } else {
                    charactersToDisplay = 600;
                }
                
                if (charactersToDisplay > fullText!.characters.count){
                    cell.fullText = fullText!;
                    cell.tvDescriptionText.text = fullText!;
                } else {
                    let tempIndex = fullText!.startIndex.advancedBy(+charactersToDisplay);
                    let shortText = fullText!.substringToIndex(tempIndex);
                    let index = shortText.rangeOfString(".", options: .BackwardsSearch)!.endIndex;
                    
                    cell.fullText = fullText;
                    cell.tvDescriptionText.text = shortText.substringToIndex(index) + " [...]";
                    cell.btnMoreText.enabled = true;
                }
            }
            
            return cell;
        }
    }
}
