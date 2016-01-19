//
//  DenkmalMapAnnotation.swift
//  DenkmälerBerlin
//
//  Created by Max on 31.10.15.
//  edited by Chris
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import UIKit
import MapKit
import AddressBook

class DMBDenkmalMapAnnotation: NSObject, MKAnnotation {
    let title: String?
    let type: String?
    let coordinate: CLLocationCoordinate2D
    let monument: DMBMonument
    
    init(title: String, type: String, coordinate: CLLocationCoordinate2D, monument: DMBMonument) {
        self.title = title
        self.type = type
        self.coordinate = coordinate
        self.monument = monument
        
        
        super.init()
    }
    
    var subtitle: String? = "Platzhalter"
    
    
    
    
    /** Hilffunktion, die aus der "Landmark" ein MKMapItem macht, mit dem man dann die Funktionalitaeten
     *  der MapApp nutzen kann (Routenberechnung)
     *
     *  @return MKMapItem
     **/
    func landmarkToMKMapItem() -> MKMapItem {
        let addressDictionary = [String(kABPersonAddressStreetKey): self.subtitle as! AnyObject]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        
        print("addressDictionary: ")
        print(addressDictionary.keys)
        print("palcemark: " + placemark.description)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        print("mapItem: " + mapItem.description)
        
        
        return mapItem
    }
}
