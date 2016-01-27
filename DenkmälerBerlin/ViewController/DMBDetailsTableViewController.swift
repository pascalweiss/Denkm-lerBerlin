//
//  DetailsTableViewController.swift
//  DenkmälerBerlin
//
//  Created by Max on 10.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import UIKit
import MapKit

class DMBDetailsTableViewController: UITableViewController, MKMapViewDelegate, NSURLSessionDownloadDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var downloadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .Standard
            mapView.showsPointsOfInterest = false
            mapView.userInteractionEnabled = false
            mapView.delegate = self
        }
    }
    
    var imageView: UIImageView!;
    var imageStatusLabel: UILabel!;
    var monument: DMBMonument! = DMBModel.sharedInstance.getAllMonuments()[12];
    var monumentData: Dictionary<String, String>! = Dictionary<String, String>();
    var printOrder: [String] = ["Adresse", "Bauzeit", "Beschreibung"];
    var descriptionPosition = 0;
    var heightForDescriptionCell:CGFloat = 0;

    
    override func viewDidLoad() {
        super.viewDidLoad();
        // initialize Views
        imageStatusLabel = UILabel.init();
        imageStatusLabel.hidden = true;
        imageView = UIImageView.init(frame: CGRect(x: self.mapView.frame.origin.x, y: self.mapView.frame.origin.y, width: UIScreen.mainScreen().bounds.width, height: self.mapView.frame.height));
        imageView.hidden = true;
        self.view.addSubview(imageStatusLabel);
        self.view.addSubview(imageView);
        // set random properties
        tableView.bounces = false;
        downloadIndicator.hidesWhenStopped = true;
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
                dateString = dateFormater.stringFromDate(monCreationPeriod!.getFrom()!);
            }
            if (monCreationPeriod?.getTo() != nil) {
                dateString += " - " +  dateFormater.stringFromDate(monCreationPeriod!.getTo()!);
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
            self.mapView.showAnnotations([anno], animated: true);
        }
        
        // Picture for Header
        let picURL: NSURL?;
        let strURL = self.monument!.getPicUrl()
        picURL = strURL.count == 0 ? nil : NSURL.init(string: strURL[0].getURL()!);
        if (picURL != nil){
            // get picture from URL
            downloadIndicator.startAnimating();
            let config = NSURLSessionConfiguration.defaultSessionConfiguration();
            let session = NSURLSession.init(configuration: config, delegate: self, delegateQueue: nil);
            let downloadTask = session.downloadTaskWithURL(picURL!);
            downloadTask.resume();
        }
        
        // The height is calculated as follows: screenHeight - (navigationbarHeight + headerviewHeight + sectionheaderHeight + height of the other rows)
        heightForDescriptionCell = UIScreen.mainScreen().bounds.height - (self.navigationController!.navigationBar.frame.height + self.mapView.frame.height + CGFloat(28) + CGFloat(printOrder.count * 44));
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - NSURLSession Delegates
    
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        downloadIndicator.stopAnimating();
        if (error != nil) {
            setImageStatusLabelWithMessage("Fehler beim Herunterladen des Bildes");
            print(error!);
        } else {
            setImageStatusLabelWithMessage("Bild Download unerwartet beendet");
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        downloadIndicator.stopAnimating();
        if (error != nil) {
            setImageStatusLabelWithMessage("Fehler beim Herunterladen des Bildes");
            print(task.response!);
            print(error!);
        } else {
            setImageStatusLabelWithMessage("Kein Bild vorhanden");
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        let imageData: NSData? = NSData.init(contentsOfURL: location);
        let image: UIImage? = UIImage.init(data: imageData!);
        if (image != nil){
            // make image view
            imageView.image = image;
            imageView.contentMode = .ScaleAspectFill;
            imageView.clipsToBounds = true;
            // add image view to superview
            imageView.hidden = false;
        } else {
            setImageStatusLabelWithMessage("Fehler beim Anzeigen des Bildes");
        }
        downloadIndicator.stopAnimating();
    }
    
    // MARK: - MessageLabel LifeCycle
    
    private func setImageStatusLabelWithMessage(message: String){
        let mes = NSString.init(string: message);
        let size = mes.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(17.0)]);
        imageStatusLabel.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height);
        imageStatusLabel.text = message;
        imageStatusLabel.center.x = mapView.center.x;
        imageStatusLabel.hidden = false;
        let labelTimer = NSTimer(timeInterval: 20.0, target: self, selector: Selector("timerFired"), userInfo: nil, repeats: false);
        NSRunLoop.mainRunLoop().addTimer(labelTimer, forMode: NSRunLoopCommonModes);
    }
    
    func timerFired(){
        print("fired");
        imageStatusLabel.hidden = true;
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
            return heightForDescriptionCell;
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
            cell.tvDescriptionText.bounces = false;
            cell.tvDescriptionText.scrollEnabled = false;
            
            let currentKey = printOrder[indexPath.row];
            cell.labelDescriptionHeading.text = currentKey;
            let fullText: String? = monumentData.count == 0 ? "" : monumentData[currentKey];
            if (fullText != nil) {
                // truncate text if neccessary
                cell.fullText = fullText!;
                cell.tvDescriptionText.text = fullText!;
                var heightOfTextToDisplay = calculateHeightOfText(fullText!, width: cell.bounds.width, font: UIFont.systemFontOfSize(14));
                
                if (heightOfTextToDisplay > heightForDescriptionCell - 10){
                    // truncating the text works as follows:
                    // 1. The text is shortened by 20 characters from the back
                    // 2. The next end of the sentence is searched (also backwards)
                    // 3. The text is truncated to this point and a height is calculated
                    // 4. That height is compared to the height of the TextField
                    //    These steps are repeated until the height of the truncated text
                    //    is smaller than the height of the TextField
                    var shortText: String;
                    shortText = fullText!;
                    
                    repeat {
                        let tempIndex = shortText.endIndex.advancedBy(-20);
                        shortText = shortText.substringToIndex(tempIndex);
                        let pointIndex = shortText.rangeOfString(".", options: .BackwardsSearch)!.endIndex;
                        shortText = shortText.substringToIndex(pointIndex);
                        heightOfTextToDisplay = calculateHeightOfText(shortText, width: cell.bounds.width, font: UIFont.systemFontOfSize(14));
                        
                    } while (heightOfTextToDisplay > heightForDescriptionCell - 10);
                    
                    cell.btnMoreText.enabled = true;
                    cell.tvDescriptionText.text = shortText + " [...]";
                }
            }
            return cell;
        }
    }
    
    private func calculateHeightOfText(text: String, width: CGFloat, font: UIFont) -> CGFloat {
        let tempString = NSString(string: text);
        let context: NSStringDrawingContext = NSStringDrawingContext();
        context.minimumScaleFactor = 0.8;
        let width: CGFloat = CGFloat(width);
        
        let frame = tempString.boundingRectWithSize(CGSizeMake(width, 2000), options:NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: context);
        
        return frame.size.height;
    }
    
    // MARK: - Map
    
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
}

//Stash
/*
str.boundingRectWithSize(cell.tvDescriptionText.bounds.size, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14.0)], context: nil);

print(sizeOfTextToDisplay.height);
print(sizeOfTextToDisplay.width);
print(cell.tvDescriptionText.bounds.size.height);
print(cell.tvDescriptionText.bounds.size.width);
*/
