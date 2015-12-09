//
//  DMBConverter.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 08.12.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation
import SQLite

struct DMBConverter {
    static func rowToMonument(row: SQLite.Row, connection: Connection) -> DMBMonument {
        return DMBMonument(
            dbConnection:       connection,
            id:                 row[DMBMonument.Expressions.id],
            name:               row[DMBMonument.Expressions.name],
            objNr:              row[DMBMonument.Expressions.objNr],
            descr:              row[DMBMonument.Expressions.descr],
            type_id:            row[DMBMonument.Expressions.typeId],
            super_monument_id:  row[DMBMonument.Expressions.superMonumentId],
            link_id:            row[DMBMonument.Expressions.linkId],
            datingId:           row[DMBMonument.Expressions.datingId]
        )
    }
    
    static func rowToMonument(row: SQLite.Row, connection: Connection, table: Table) -> DMBMonument {
        return DMBMonument(
            dbConnection:       connection,
            id:                 row[table[DMBMonument.Expressions.id]],
            name:               row[table[DMBMonument.Expressions.name]],
            objNr:              row[table[DMBMonument.Expressions.objNr]],
            descr:              row[table[DMBMonument.Expressions.descr]],
            type_id:            row[table[DMBMonument.Expressions.typeId]],
            super_monument_id:  row[table[DMBMonument.Expressions.superMonumentId]],
            link_id:            row[table[DMBMonument.Expressions.linkId]],
            datingId:           row[table[DMBMonument.Expressions.datingId]]
        )
    }
    
    static func rowToAddress(row: SQLite.Row, connection: Connection, table: Table) -> DMBLocation {
        return DMBLocation(
            id:         row[table[DMBLocation.Expressions.id]],
            lat:        row[table[DMBLocation.Expressions.lat]],
            long:       row[table[DMBLocation.Expressions.long]],
            street:     row[table[DMBLocation.Expressions.street]],
            nr:         row[table[DMBLocation.Expressions.nr]])
    }
    
    static func rowToType(row: SQLite.Row, connection: Connection) -> DMBType {
        return DMBType(
            dbConnection:   connection,
            id:             row[DMBType.Expressions.id],
            name:           row[DMBType.Expressions.name])
    }
    
    static func rowToType(row: SQLite.Row, connection: Connection, table: Table) -> DMBType {
        return DMBType(
            dbConnection:   connection,
            id:             row[table[DMBType.Expressions.id]],
            name:           row[table[DMBType.Expressions.name]])
    }
    
    
    static func rowToTimePeriod(row: SQLite.Row, connection: Connection, table: Table) -> DMBTimePeriod {
        let rowFrom = row[table[DMBTimePeriod.Expressions.from]]
        let rowTo   = row[table[DMBTimePeriod.Expressions.to]]
        return DMBTimePeriod(
            dbConnection:   connection,
            id:             row[table[DMBTimePeriod.Expressions.id]],
            from:           {rowFrom != nil ? DMBConverter.stringToDate(rowFrom!):nil}(),
            to:             {rowTo != nil ? DMBConverter.stringToDate(rowTo!):nil}())
    }
    
    static func rowToNotion(row: SQLite.Row, connection: Connection) -> DMBNotion {
        return DMBNotion(
            dbConnection:   connection,
            id:             row[DMBNotion.Expressions.id],
            name:           row[DMBNotion.Expressions.name])
    }
    
    static func rowToDistrict(row: SQLite.Row, connection: Connection, table: Table) -> DMBDistrict {
        return DMBDistrict(
            dbConnection:   connection,
            id:             row[table[DMBDistrict.Expressions.id]],
            name:           row[table[DMBDistrict.Expressions.name]])
    }
    
    static func rowToSubDistrict(row: SQLite.Row, connection: Connection, table: Table) -> DMBSubDistrict {
        return DMBSubDistrict(
            dbConnection:   connection,
            id:             row[table[DMBDistrict.Expressions.id]],
            name:           row[table[DMBDistrict.Expressions.name]])
    }
    
    static func rowToDistrict(row: SQLite.Row, connection: Connection) -> DMBDistrict {
        return DMBDistrict(
            dbConnection:   connection,
            id:             row[DMBDistrict.Expressions.id],
            name:           row[DMBDistrict.Expressions.name])
    }
    
    static func stringToDate(s:String) -> NSDate? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.dateFromString(s)
    }
}