//
//  DMBModel.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 18.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation
import SQLite
import MapKit

class DMBModel {
    
    static let sharedInstance = DMBModel()
    private let dbConnection: Connection
    private var filter: DMBFilter?
    private let debug = true

    private init() {
        print(NSBundle.mainBundle().pathForResource("DMBsqlite_v6", ofType: "db"))
        self.dbConnection = try! Connection(NSBundle.mainBundle().pathForResource("DMBsqlite_v6", ofType: "db")!, readonly: false)
//        DMBDummyData.createDummyData(self.dbConnection) //TODO remove
    }
    
    func setFilter(filter:DMBFilter) {
        self.filter=filter
    }
    
    func getAllParticipants()->[DMBParticipant]{
        return []
    }
    
    func getAllEpoches()->[DMBEpoche] {
        assert(false, "getAllMonuments() not implemented yet. I will do if required")
        return []
    }
    
    func getAllDistricts()->[String] {
        assert(false, "getAllMonuments() not implemented yet. I will do if required")
        return []
    }
    
    func getAllRoutes()->[DMBRoute] {
        assert(false, "getAllMonuments() not implemented yet. I will do if required")
        return []
    }
    
    func getAllMonumentTypes()->[DMBType] {
        let types = Table(DMBTable.type)
        return dbConnection.prepare(types).map{row -> DMBType in
            return DMBConverter.rowToType(row, connection: dbConnection)
        }
    }
    
    func getAllMonuments() -> [DMBMonument] {
        let monuments = Table(DMBTable.monument)
        return dbConnection.prepare(monuments)
            .map({row -> DMBMonument in
                return DMBConverter.rowToMonument(row, connection: dbConnection)
        })
    }
    
    
    func getMonuments(area:MKCoordinateRegion) -> [DMBMonument]{
        let monuments  = Table(DMBTable.monument)
        let addresses  = Table(DMBTable.address)
        let addressRel = Table(DMBTable.addressRel)
        let inLongitude = area.center.longitude - area.span.longitudeDelta < DMBAddress.Expressions.long
            && DMBAddress.Expressions.long < area.center.longitude + area.span.longitudeDelta
        let inLatitude  = area.center.latitude - area.span.latitudeDelta < DMBAddress.Expressions.lat
            && DMBAddress.Expressions.lat < area.center.latitude + area.span.latitudeDelta
        return dbConnection.prepare(monuments
            .join(addressRel, on: monuments[DMBMonument.Expressions.id] == addressRel[DMBAddressRelation.Expressions.monumentId])
            .join(addresses, on: addressRel[DMBAddressRelation.Expressions.addressId] == addresses[DMBAddress.Expressions.id])
            .filter(inLongitude && inLatitude))
            .map({row -> DMBMonument in
                return DMBConverter.rowToMonument(row, connection: dbConnection)
        })
    }
    
    func getMonumentsWithRegexByName(regex: String) -> [DMBMonument] {
        let monuments = Table(DMBTable.monument)
        return dbConnection.prepare(monuments
            .filter(monuments[DMBMonument.Expressions.name].lowercaseString.like(regex)))
            .map({row -> DMBMonument in
                return DMBConverter.rowToMonument(row, connection: dbConnection)
            })
    }
}
