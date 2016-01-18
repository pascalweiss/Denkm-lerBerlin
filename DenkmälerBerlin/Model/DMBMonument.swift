//
//  DMBMonument.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 19.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation
import SQLite

/// Repräsentiert die Datenbank-Entität "monument". 
/// Liefert Informationen zu bestimmten Denkmälern
class DMBMonument: DMBEntity {
    
    struct Expressions {
        static let monuments = Table(DMBTable.monument)
        static let id      =            Expression<Int?>(DMBAttribut.id)
        static let name    =            Expression<String?>(DMBAttribut.name)
        static let objNr   =            Expression<String?>(DMBAttribut.objNr)
        static let descr   =            Expression<String?>(DMBAttribut.descr)
        static let typeId  =            Expression<Int?>(DMBAttribut.typeId)
        static let superMonumentId =    Expression<Int?>(DMBAttribut.superMonumentId)
        static let linkId  =            Expression<Int?>(DMBAttribut.linkId)
        static let datingId =           Expression<Int?>(DMBAttribut.datingId)
    }
    
    private let id:Int?
    private let name:String?
    private let objNr:String?
    private let descr:String?
    private let type_id:Int?
    private let super_monument_id:Int?
    private let link_id:Int?
    private var addresses:[DMBLocation]?
    private let datingId:Int?
    
    init(dbConnection: Connection, id: Int?, name:String?, objNr:String?, descr:String?, type_id:Int?, super_monument_id:Int?, link_id:Int?, datingId: Int?) {
        self.id = id
        self.name = name
        self.objNr = objNr
        self.descr = descr
        self.type_id = type_id
        self.super_monument_id = super_monument_id
        self.link_id = link_id
        self.datingId = datingId
        super.init(dbConnection: dbConnection)
    }
    init(dbConnection: Connection, id: Int?, name:String?, objNr:String?, descr:String?, type_id:Int?, super_monument_id:Int?, link_id:Int?, datingId: Int?, addresses:[DMBLocation]?) {
        self.id = id
        self.name = name
        self.objNr = objNr
        self.descr = descr
        self.type_id = type_id
        self.super_monument_id = super_monument_id
        self.link_id = link_id
        self.datingId = datingId
        super.init(dbConnection: dbConnection)
    }
    
    /// Der Name des Denkmals
    func getName()->String? {
        return name
    }
    
    /// Die Objektnummer des Denkmals
    func getObjNr()->String? {
        return objNr
    }
    
    /// Die URLs sämtlicher Bilder des Denkmals
    func getPicUrl()->[DMBPictureURL] {
        let pictureURLs = Table(DMBTable.picture)
        let monuments = Table(DMBTable.monument)
        return dbConnection.prepare(monuments
            .join(pictureURLs, on: monuments[DMBMonument.Expressions.id] == pictureURLs[DMBPictureURL.Expressions.monumentId])
            .filter(monuments[DMBMonument.Expressions.id] == self.id))
            .map({row -> DMBPictureURL in
                return DMBConverter.rowToPictureURL(row,table: pictureURLs)
            })
    }
    
    /// Liefert die textuelle Beschreibung des Denkmals
    func getDescription()->String?{
        return descr
    }
    
    /// Liefert sämtliche Bezirke, in denen sich das Denkmal befindet 
    /// (...ja, manche Denkmäler gehören zu mehr als 1 Bezirk)
    /// Als Rückgabewert erhälst du ein Array vom Typ DMBDistrict
    /// Diese können z.B. folgende Bezirke repräsentieren: "Prenzlauer Berg", "Neukölln", etc.
    func getDistricts()->[DMBDistrict] {
        let districts = Table(DMBTable.district)
        let monuments = Table(DMBTable.monument)
        let districtRel = Table(DMBTable.districtRel)
        return dbConnection.prepare(districts
            .join(districtRel, on: districts[DMBDistrict.Expressions.id] == districtRel[DMBDistrictRelation.Expressions.districtId])
            .join(monuments, on: districtRel[DMBDistrictRelation.Expressions.monumentId] == monuments[DMBMonument.Expressions.id])
            .filter(monuments[DMBMonument.Expressions.id] == id))
            .map({row -> DMBDistrict in
                return DMBConverter.rowToDistrict(row, connection: dbConnection, table: districts)
                
            })
    }
    
    /// Liefert sämtliche Stadtteile, in denen sich das Denkmal befindet
    /// (...ja, manche Denkmäler gehören zu mehr als 1 Stadtteil)
    /// Als Rückgabewert erhälst du ein Array vom Typ DMBSubDistrict
    /// Diese können z.B. folgende Stadtteil repräsentieren: "Dahlem", "Zehlendorf", etc.
    func getSubDistricts()->[DMBSubDistrict] {
        let subDistricts = Table(DMBTable.subDistrict)
        let monuments = Table(DMBTable.monument)
        let subDistrictRel = Table(DMBTable.subDistrictRel)
        return dbConnection.prepare(subDistricts
            .join(subDistrictRel, on: subDistricts[DMBSubDistrict.Expressions.id] == subDistrictRel[DMBSubDistrictRelation.Expressions.subDistrictId])
            .join(monuments, on: subDistrictRel[DMBSubDistrictRelation.Expressions.monumentId] == monuments[DMBMonument.Expressions.id])
            .filter(monuments[DMBMonument.Expressions.id] == id))
            .map({row -> DMBSubDistrict in
                return DMBConverter.rowToSubDistrict(row, connection: dbConnection, table: subDistricts)
            })
    }
    
    func getRoutes()->[DMBRoute] {  //TODO
        return []
    }
    
    // Liefert den Denkmaltyp des Denkmals. Z.B. "Baudenkmal" oder "Ensemble"
    func getType() -> DMBType? {
        let types = Table(DMBTable.type)
        let monuments = Table(DMBTable.monument)
        let row = dbConnection.pluck(types
            .join(monuments, on: monuments[DMBMonument.Expressions.typeId] == types[DMBType.Expressions.id])
            .filter(monuments[DMBMonument.Expressions.id] == id))
        if (row != nil) {
            return DMBConverter.rowToType(row!, connection: dbConnection, table: types)
        }
        return nil
    }
    /// Liefert sämtliche Objekttypen, wie z.B. "Brücke", "Brunnen", etc.
    /// Als Rückgabewert erhälst du ein Array vom Typ DMBNotion
    func getNotions() -> [DMBNotion]{
        let notions = Table(DMBTable.monumentNotion)
        let monuments = Table(DMBTable.monument)
        let notionsRels = Table(DMBTable.monumentNotionRel)
        return dbConnection.prepare(notions
            .join(notionsRels, on: notions[DMBNotion.Expressions.id] == notionsRels[DMBNotionsRelation.Expressions.monumentNotionId])
            .join(monuments, on: notionsRels[DMBNotionsRelation.Expressions.monumentId] == self.id)
            .filter(id == monuments[DMBMonument.Expressions.id]))
            .map({row -> DMBNotion in
                return DMBConverter.rowToNotion(row, connection: dbConnection, table: notions)
            })
    }
    
    /// Liefert den Zeitraum, in dem das Denkmal entstanden ist,
    /// in Form eines Objektes vom Typ DMBTimePeriod
    func getCreationPeriod()->DMBTimePeriod? {
        let monuments = Table(DMBTable.monument)
        let datings = Table(DMBTable.dating)
        let row = dbConnection.pluck(monuments
            .join(datings, on: self.datingId == datings[DMBTimePeriod.Expressions.id]))
        if row != nil {
            return DMBConverter.rowToTimePeriod(row!, connection: dbConnection, table: datings)
        }
        return nil
    }
    
    /// Liefert die Ortsdaten für das jeweilige Denkmal (Straße, Hausnummer, Longitude, Latitude)
    /// In Form einer DMBLocation
    func getAddress()->DMBLocation{
        let addresses   = Table(DMBTable.address)
        let addressRel  = Table(DMBTable.addressRel)
        let monuments = Table(DMBTable.monument)
        return dbConnection.pluck(addresses
            .join(addressRel, on: addresses[DMBLocation.Expressions.id] == addressRel[DMBLocationRelation.Expressions.addressId])
            .join(monuments, on: monuments[DMBMonument.Expressions.id] == addressRel[DMBLocationRelation.Expressions.monumentId])
            .filter(addressRel[DMBLocationRelation.Expressions.monumentId] == self.id))
            .map({row -> DMBLocation in
                return DMBConverter.rowToAddress(row, connection: dbConnection, table: addresses)
            })!
    }
    
    func getParticipants()->[DMBParticipant] {
        let participants = Table(DMBTable.participant)
        let particpantRel = Table(DMBTable.participantRel)
        let monuments = Table(DMBTable.monument)
        return dbConnection.prepare(monuments
            .join(particpantRel, on: monuments[DMBMonument.Expressions.id] == particpantRel[DMBParticipantsRelation.Expressions.monumentId])
            .join(participants, on: particpantRel[DMBParticipantsRelation.Expressions.participantId] == participants[DMBParticipant.Expressions.id])
            .filter(monuments[DMBMonument.Expressions.id] == self.id))
            .map({row -> DMBParticipant in
                return DMBConverter.rowToParticipant(row, connection: dbConnection, table: participants)
            })
    }
    
    func getLinkedMonuments()->[DMBMonument] {  //TODO
        return []
    }
    
    func getSuperMonument()->DMBMonument? {  //TODO
        return nil
    }
    
    func getSubMonuments()->[DMBMonument] { //TODO
        return []
    }
    
    /// Convenient Methode zur Ausgabe in der Console
    func printIt() {
        print("\nDMBMonument")
        print("===========")
        print("id:              \(id)")
        print("name:            \(name)")
        print("objNr:           \(objNr)")
        print("descr:           \(descr)")
        print("typeId:          \(type_id)")
        print("superMonumentId: \(super_monument_id)")
        print("linkId:          \(link_id)")
        print("datingId:        \(datingId)")
    }
}

