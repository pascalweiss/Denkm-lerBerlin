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
        monuments_1[0...3].forEach{m in m.printIt()}
//        monuments_1.forEach{m in m.printIt()}
        
        // You can query all monuments in a specific area
        let area = MKCoordinateRegion.init(
            center: CLLocationCoordinate2D.init(latitude: 52.5243700, longitude: 13.4105300),
            span: MKCoordinateSpan.init(latitudeDelta: 0.001, longitudeDelta: 0.001))
        let monuments_2:[DMBMonument] = DMBModel.sharedInstance.getMonuments(area)    
        monuments_2.forEach{m in m.printIt()}
        
        // get all types
        let t = DMBModel.sharedInstance.getAllTypes()
        t.forEach{t in t.printIt()}
        
        // Every subclass of DMBEntity can query the database on itself.
        // For example you can query the addresses of a monument
        let mon_1:DMBMonument = monuments_1[0]
        let address:DMBLocation = mon_1.getAddress()
        address.printIt()
        
        // Or you can query for the participants
        let participants:[DMBParticipant] = mon_1.getParticipants()
        participants.forEach({p in p.printIt()})
        
        for mon in monuments_1[0...20] {
            let pictureURLs: [DMBPictureURL] = mon.getPicUrl()
            pictureURLs.forEach({p in p.printIt()})
        }
        
        let notions: [DMBNotion] = monuments_1[0].getNotions()
        notions.forEach({p in p.printIt()})
        notions.forEach({p in print(p.getName())})
        
        
        // get type of a specific monument
        mon_1.getType()
        
        // get timePeriods of a specific monument
        let timePeriod = mon_1.getCreationPeriod()
        if timePeriod != nil && timePeriod?.getFrom() != nil {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy"
            print("\ngetFrom: \n=======\n"+formatter.stringFromDate(timePeriod!.getFrom()!))
        }
        
        // get districs of a specific monument
        mon_1.getDistricts().forEach({d in d.printIt()})
        
        // get subdistrics of a specific monument
        mon_1.getSubDistricts().forEach({sd in sd.printIt()})

        // Search Monuments with a search String
        let monumentsSearch = DMBModel.sharedInstance.searchMonuments("Brandenburg Schiller Tor Tor")
        print("\nSearch results by monument name:\n" +
                "================================\n")
        monumentsSearch[DMBSearchKey.byName]!.forEach({t in
            print("Ranking: \(t.0)")
            t.1.printIt()
        })
        print("\nSearch results by location:\n" +
                "===========================\n")
        monumentsSearch[DMBSearchKey.byLocation]!.forEach({t in
            print("Ranking: \(t.0)")
            t.1.printIt()
        })
        print("\nSearch results by notion:\n" +
                "=========================\n")
        monumentsSearch[DMBSearchKey.byNotion]!.forEach({t in
            print("Ranking: \(t.0)")
            t.1.printIt()
        })
        print("\nSearch results by participant:\n" +
                "==============================\n")
        monumentsSearch[DMBSearchKey.byParticipant]!.forEach({t in
            print("Ranking: \(t.0)")
            t.1.printIt()
        })

        // get all districts
        DMBModel.sharedInstance.getAllDistricts().forEach({d in d.printIt()})
        
        // get the earliest date
        print("\nEarliest date:\n" +
                "==============\n" +
                String(DMBModel.sharedInstance.getMinDate()))
        
        // get the most recent date
        print("\nMost recent date:\n" +
                "=================\n"+String(DMBModel.sharedInstance.getMaxDate()))
        
        print("\nHistory:\n" +
                "========\n")
        // Add entries to the history
        DMBModel.sharedInstance.setHistoryEntry("HTWBerlin")
        DMBModel.sharedInstance.setHistoryEntry("Pascals Schloss")
        DMBModel.sharedInstance.setHistoryEntry("Süssigkeitenfabrik")
        
        // Get History Entries
        DMBModel.sharedInstance.getHistory().forEach({h in h.printIt()})
        

        print("\nSearch with filter:\n" +
            "===================\n")
        
        // filtered search: set the filter to whatever you like
        DMBModel.sharedInstance.filter.baudenkmal               = false
        DMBModel.sharedInstance.filter.friedrichshainKreuzberg  = false
        
        // ... and call the searchMonumentsWithFilter function, by passing the query string
        let mon_filter = DMBModel.sharedInstance.searchMonumentsWithFilter("Brandenburg")
        mon_filter[DMBSearchKey.byName]?[0...1].forEach({m in m.1.printIt()})
        
        
        print("\nGet Notions of monument" +
                "=======================\n")
        monuments_1[0...10].forEach({m in m.printIt();m.getNotions().forEach({n in n.printIt()})})
    }
}