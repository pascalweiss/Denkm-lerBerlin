//
//  DMBMonument.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 19.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation
import SQLite

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
    private var addresses:[DMBAddress]?
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
    init(dbConnection: Connection, id: Int?, name:String?, objNr:String?, descr:String?, type_id:Int?, super_monument_id:Int?, link_id:Int?, datingId: Int?, addresses:[DMBAddress]?) {
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
    
    // e.g. Brandenburger Tor
    func getName()->String? {
        return name
    }
    
    func getObjNr()->String? {
        return objNr
    }
    
    func getPicUrl()->NSURL? {  //TODO
        return NSURL(string: "http://dummy.url.com")
    }
    
    func getDescription()->String?{
        return descr
    }
    
    // e.g. Charlottenburg-Wilmersdorf
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
    
    // e.g. Charlottenburg
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
    
    // e.g. Baudenkmal
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
    
    func getMonumentNotions() -> [DMBMonumentNotion]{
        let notions = Table(DMBTable.monumentNotion)
        let monuments = Table(DMBTable.monument)
        let notionsRels = Table(DMBTable.monumentNotionRel)
        return dbConnection.prepare(notions
            .join(notionsRels, on: notions[DMBMonumentNotion.Expressions.id] == notionsRels[DMBNotionsRelation.Expressions.monumentNotionId])
            .join(monuments, on: notionsRels[DMBNotionsRelation.Expressions.monumentId] == notionsRels[DMBMonument.Expressions.id])
            .filter(id == monuments[DMBMonument.Expressions.id]))
            .map({row -> DMBMonumentNotion in
                return DMBConverter.rowToNotion(row,connection: dbConnection)
            })
    }
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
    
    func getAddress()->DMBAddress{
        let addresses   = Table(DMBTable.address)
        let addressRel  = Table(DMBTable.addressRel)
        let monuments = Table(DMBTable.monument)
        let res =  dbConnection.pluck(addresses
            .join(addressRel, on: addresses[DMBAddress.Expressions.id] == addressRel[DMBAddressRelation.Expressions.addressId])
            .join(monuments, on: monuments[DMBMonument.Expressions.id] == addressRel[DMBAddressRelation.Expressions.monumentId])
            .filter(addressRel[DMBAddressRelation.Expressions.monumentId] == self.id))
            .map({row -> DMBAddress in
                return DMBConverter.rowToAddress(row, connection: dbConnection, table: addresses)
            })
        return res!
    }
    
    func getParticipants()->[DMBParticipant] {  //TODO
        return []
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

