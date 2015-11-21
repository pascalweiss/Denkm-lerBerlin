//
//  DMBModelEXAMPLES.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 21.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation
import MapKit

struct DMBModelEXAMPLES {

    static func run() {
        // Access the model via DMBModel.sharedInstance 
        // (You don't have to instantiate it, it's a Singleton).
        DMBModel.sharedInstance
        
        // You can query all monuments
        let monuments_1:[DMBMonument] = DMBModel.sharedInstance.getAllMonuments()
        monuments_1.forEach{m in m.printIt()}
        
        // You can query all monuments in a specific area
        let area = MKCoordinateRegion.init(
            center: CLLocationCoordinate2D.init(latitude: 52.5243700, longitude: 13.4105300),
            span: MKCoordinateSpan.init(latitudeDelta: 0.1, longitudeDelta: 0.1))
        let monuments_2:[DMBMonument] = DMBModel.sharedInstance.getMonuments(area)
        monuments_2.forEach{m in m.printIt()}
        
        // get all types
        let t = DMBModel.sharedInstance.getAllMonumentTypes()
        t.forEach{t in t.printIt()}
        
        // Every subclass of DMBEntity can query die database on itself.
        // For example you can query the addresses of a monument
        let mon_1:DMBMonument = monuments_1[0]
        let addresses:[DMBAddress] = mon_1.getAddresses()
        addresses.forEach{a in a.printIt()}
        
        // get type of a specific monument
        mon_1.getType()
        
        // get timePeriods of a specific monument
        mon_1.getCreationPeriods().forEach{cp in cp.printIt()}
        
        // get districs of a specific monument
        mon_1.getDistricts().forEach({d in d.printIt()})
        
        // get subdistrics of a specific monument
        mon_1.getSubDistricts().forEach({sd in sd.printIt()})
        
    }
}