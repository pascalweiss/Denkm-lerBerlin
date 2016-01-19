//
//  DetailsTableViewController.swift
//  DenkmälerBerlin
//
//  Created by Max on 10.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import UIKit
import MapKit

class DMBDetailsTableViewController: UITableViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var mapView: MKMapView!
    
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
        if (monument.getName() != nil){
            monumentData.updateValue(monument.getName()!, forKey: "Name");
            
        }
        
        // Description
        if (monument.getDescription() != nil){
            monumentData.updateValue(monument.getDescription()!, forKey: "Beschreibung");
        }
        
        // Date
        if (monument.getCreationPeriod() != nil){
            var dateString: String = "";
            let dateFormater = NSDateFormatter.init();
            dateFormater.timeZone = NSTimeZone(name: "Europe/Berlin");
            dateFormater.locale = NSLocale(localeIdentifier: "de-DE");
            dateFormater.dateFormat = "MMMM yyyy";
            if (monument.getCreationPeriod()?.getFrom() != nil){
                dateString = dateFormater.stringFromDate(monument.getCreationPeriod()!.getFrom()!) + " - ";
            }
            if (monument.getCreationPeriod()?.getTo() != nil) {
                dateString += dateFormater.stringFromDate(monument.getCreationPeriod()!.getTo()!);
            }
            monumentData.updateValue(dateString, forKey: "Bauzeit");
        }
        
        // Address
        var addressString: String = "";
        if (monument.getAddress().getStreet() != nil){
            addressString = monument.getAddress().getStreet()! + " ";
        }
        if (monument.getAddress().getNr() != nil) {
            addressString += monument.getAddress().getNr()!;
        }
        if (addressString != ""){
            monumentData.updateValue(addressString, forKey: "Adresse");
        }
        
        
        // Picture for Header
        let picURL: NSURL?;
//        picURL = NSURL.init(string: "https://thumbs.dreamstime.com/z/berlin-above-aerial-view-center-germany-35821603.jpg");
        let strURL = monument!.getPicUrl()
        picURL = strURL.count == 0 ? nil : NSURL.init(string: strURL[0].getURL()!);
        if (picURL != nil){
            // get picture from URL
            let imageData: NSData? = NSData.init(contentsOfURL: picURL!)!;
            if (imageData != nil){
                let image: UIImage? = UIImage.init(data: imageData!);
                if (image != nil){
                    // make image view
                    let imageView = UIImageView.init(frame: CGRect(x: mapView.frame.origin.x, y: mapView.frame.origin.y, width: UIScreen.mainScreen().bounds.width, height: mapView.frame.height));
                    imageView.image = image;
                    imageView.contentMode = .ScaleAspectFill;
                    imageView.clipsToBounds = true;
                    // add image view to superview
                    self.view.addSubview(imageView);
                }
            }
        } else {
            // show object on map
            if (monument.getAddress().getLat() != nil && monument.getAddress().getLong() != nil) {
                // center map on monument coordinates
                let lat = monument.getAddress().getLat()!;
                let long = monument.getAddress().getLong()!;
                let monumentCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: long);
                
                // add Annotation
                let address = monument.getAddress()
                let anno = DMBDenkmalMapAnnotation.init(title: monument.getName()!, type: (monument.getType()?.getName()!)!, coordinate: CLLocationCoordinate2D(latitude: long, longitude: lat), monument: monument)
                
                var street = address.getStreet()
                street = street != nil ? street : ""
                var number = address.getNr()
                number = number != nil ? number : ""
                anno.subtitle = street! + " " + number!
                
                mapView.addAnnotation(anno);
                
                mapView.centerCoordinate = monumentCoordinate;
                mapView.showAnnotations([anno], animated: true);
            }
        }
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
