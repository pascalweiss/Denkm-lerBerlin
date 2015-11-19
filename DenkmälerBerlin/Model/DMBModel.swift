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
    static let sharedInstance = DMBModel(dbConnection: DMBDummyConnection())
    private let dbConnection: DMBDummyConnection
    private var filter: DMBFilter?
    private init(dbConnection: DMBDummyConnection) {
        self.dbConnection = dbConnection
    }
    
    func setFilter(filter:DMBFilter) {
        self.filter=filter
    }
    func getAllParticipants()->[DMBParticipant]{
        return []
    }
    func getAllEpoches()->[DMBEpoche] {
        return []
    }
    func getAllDistricts()->[String] {
        return []
    }
    func getAllMonumentTypes()->[String] {
        return []
    }
    func getAllRoutes()->[DMBRoute] {
        return []
    }
    func getMonuments(area:MKCoordinateRegion) -> [DMBMonument]{
        return []
    }
}
