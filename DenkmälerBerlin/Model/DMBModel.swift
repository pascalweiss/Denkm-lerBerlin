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
        self.dbConnection = try! Connection(NSBundle.mainBundle().pathForResource("DMBsqlite_v2", ofType: "db")!, readonly: false)
        DMBDummyData.createDummyData(self.dbConnection) //TODO remove
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
        return dbConnection.prepare(types).map{
            DMBType(
                dbConnection: dbConnection,
                id:     $0[DMBType.Expressions.id],
                name:   $0[DMBType.Expressions.name])
        }
    }
    
    func getAllMonuments() -> [DMBMonument] {
        let monuments = Table(DMBTable.monument)
        return dbConnection.prepare(monuments)
            .map({
            DMBMonument(
                dbConnection:       dbConnection,
                id:                 $0[DMBMonument.Expressions.id],
                name:               $0[DMBMonument.Expressions.name],
                objNr:              $0[DMBMonument.Expressions.objNr],
                descr:              $0[DMBMonument.Expressions.descr],
                type_id:            $0[DMBMonument.Expressions.typeId],
                super_monument_id:  $0[DMBMonument.Expressions.superMonumentId],
                link_id:            $0[DMBMonument.Expressions.linkId]
            )
        })
    }
    
    func getMonuments(area:MKCoordinateRegion) -> [DMBMonument]{
        let monuments = Table(DMBTable.monument)
        let addresses = Table(DMBTable.address)
        let inLongitude = area.center.longitude - area.span.longitudeDelta < DMBAddress.Expressions.long
            && DMBAddress.Expressions.long < area.center.longitude + area.span.longitudeDelta
        let inLatitude  = area.center.latitude - area.span.latitudeDelta < DMBAddress.Expressions.lat
            && DMBAddress.Expressions.lat < area.center.latitude + area.span.latitudeDelta
        return dbConnection.prepare(monuments
            .join(addresses, on: DMBAddress.Expressions.monumentId == monuments[DMBMonument.Expressions.id]).filter(inLongitude && inLatitude))
            .map({
            DMBMonument(
                dbConnection:       dbConnection,
                id:                 $0[monuments[DMBMonument.Expressions.id]],
                name:               $0[monuments[DMBMonument.Expressions.name]],
                objNr:              $0[monuments[DMBMonument.Expressions.objNr]],
                descr:              $0[monuments[DMBMonument.Expressions.descr]],
                type_id:            $0[monuments[DMBMonument.Expressions.typeId]],
                super_monument_id:  $0[monuments[DMBMonument.Expressions.superMonumentId]],
                link_id:            $0[monuments[DMBMonument.Expressions.linkId]]
            )
        })
    }
}
