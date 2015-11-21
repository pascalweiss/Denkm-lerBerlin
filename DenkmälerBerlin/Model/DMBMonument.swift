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
        static let objNr   =            Expression<String?>(DMBAttribut.obj_nr)
        static let descr   =            Expression<String?>(DMBAttribut.descr)
        static let typeId  =            Expression<Int?>(DMBAttribut.type_id)
        static let superMonumentId =    Expression<Int?>(DMBAttribut.super_monument_id)
        static let linkId =             Expression<Int?>(DMBAttribut.link_id)
    }
    
    private let id:Int?
    private let name:String?
    private let objNr:String?
    private let descr:String?
    private let type_id:Int?
    private let super_monument_id:Int?
    private let link_id:Int?
    private var addresses:[DMBAddress]?
    
    init(dbConnection: Connection, id: Int?, name:String?, objNr:String?, descr:String?, type_id:Int?, super_monument_id:Int?, link_id:Int?) {
        self.id = id
        self.name = name
        self.objNr = objNr
        self.descr = descr
        self.type_id = type_id
        self.super_monument_id = super_monument_id
        self.link_id = link_id
        super.init(dbConnection: dbConnection)
    }
    init(dbConnection: Connection, id: Int?, name:String?, objNr:String?, descr:String?, type_id:Int?, super_monument_id:Int?, link_id:Int?, addresses:[DMBAddress]?) {
        self.id = id
        self.name = name
        self.objNr = objNr
        self.descr = descr
        self.type_id = type_id
        self.super_monument_id = super_monument_id
        self.link_id = link_id
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
    func getDistricts()->[DMBDistrict] { //TODO
        let districts = Table(DMBTable.district)
        let monuments = Table(DMBTable.monument)
        let districtRel = Table(DMBTable.district_rel)
        return dbConnection.prepare(districts
            .join(districtRel, on: districts[DMBDistrict.Expressions.id] == districtRel[DMBDistrictRelation.Expressions.districtId])
            .join(monuments, on: districtRel[DMBDistrictRelation.Expressions.monumentId] == monuments[DMBMonument.Expressions.id])
            .filter(monuments[DMBMonument.Expressions.id] == id))
            .map({
                DMBDistrict(
                    dbConnection: dbConnection,
                    id: $0[districts[DMBDistrict.Expressions.id]],
                    name: $0[districts[DMBDistrict.Expressions.name]])
            })
    }
    
    // e.g. Charlottenburg
    func getSubDistricts()->[DMBSubDistrict] { //TODO
        let subDistricts = Table(DMBTable.sub_district)
        let monuments = Table(DMBTable.monument)
        let subDistrictRel = Table(DMBTable.sub_district_rel)
        return dbConnection.prepare(subDistricts
            .join(subDistrictRel, on: subDistricts[DMBSubDistrict.Expressions.id] == subDistrictRel[DMBSubDistrictRelation.Expressions.subDistrictId])
            .join(monuments, on: subDistrictRel[DMBSubDistrictRelation.Expressions.monumentId] == monuments[DMBMonument.Expressions.id])
            .filter(monuments[DMBMonument.Expressions.id] == id))
            .map({
                DMBSubDistrict(
                    dbConnection: dbConnection,
                    id: $0[subDistricts[DMBSubDistrict.Expressions.id]],
                    name: $0[subDistricts[DMBSubDistrict.Expressions.name]])
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
            return DMBType(dbConnection: dbConnection, id: row![types[DMBType.Expressions.id]], name: row![types[DMBType.Expressions.name]])
        }
        return nil
    }
    
    func getMonumentNotions() -> [DMBMonumentNotion]{
        let notions = Table(DMBTable.monument_notion)
        let monuments = Table(DMBTable.monument)
        let notionsRels = Table(DMBTable.monument_notion_rel)
        return dbConnection.prepare(notions
            .join(notionsRels, on: notions[DMBMonumentNotion.Expressions.id] == notionsRels[DMBNotionsRelation.Expressions.monumentNotionId])
            .join(monuments, on: notionsRels[DMBNotionsRelation.Expressions.monumentId] == notionsRels[DMBMonument.Expressions.id])
            .filter(id == monuments[DMBMonument.Expressions.id]))
            .map({
                DMBMonumentNotion(dbConnection: dbConnection, id: $0[DMBMonumentNotion.Expressions.id], name: $0[DMBMonumentNotion.Expressions.name])
            })
    }
    
    func getCreationPeriods()->[DMBTimePeriod] {
        let monuments = Table(DMBTable.monument)
        let datings = Table(DMBTable.dating)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return dbConnection.prepare(monuments
            .join(datings, on: monuments[DMBMonument.Expressions.id] == datings[DMBTimePeriod.Expressions.monumentId])
            .filter(id == monuments[DMBMonument.Expressions.id]))
            .map({
                let rowFrom = $0[datings[DMBTimePeriod.Expressions.from]]
                let rowTo   = $0[datings[DMBTimePeriod.Expressions.to]]
                return DMBTimePeriod(dbConnection: dbConnection,
                    id: $0[datings[DMBTimePeriod.Expressions.id]],
                    from: {rowFrom != nil ? formatter.dateFromString(rowFrom!):nil}(),
                    to: {rowTo != nil ? formatter.dateFromString(rowTo!):nil}(),
                    monumentId: $0[datings[DMBTimePeriod.Expressions.monumentId]])
        })
    }
    
    func getAddresses()->[DMBAddress]{
        let addresses = Table(DMBTable.address)
        return dbConnection.prepare(addresses
            .filter(DMBAddress.Expressions.monumentId == id))
            .map({
                DMBAddress(
                    id:         $0[DMBAddress.Expressions.id],
                    lat:        $0[DMBAddress.Expressions.lat],
                    long:       $0[DMBAddress.Expressions.long],
                    street:     $0[DMBAddress.Expressions.street],
                    nr:         $0[DMBAddress.Expressions.nr],
                    monumentId: $0[DMBAddress.Expressions.monumentId])
            })
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
    }
}

