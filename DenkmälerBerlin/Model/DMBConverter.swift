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
    
    static func rowToAddress(row: SQLite.Row, connection: Connection, table: Table) -> DMBAddress {
        return DMBAddress(
            id:         row[table[DMBAddress.Expressions.id]],
            lat:        row[table[DMBAddress.Expressions.lat]],
            long:       row[table[DMBAddress.Expressions.long]],
            street:     row[table[DMBAddress.Expressions.street]],
            nr:         row[table[DMBAddress.Expressions.nr]])
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
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let rowFrom = row[table[DMBTimePeriod.Expressions.from]]
        let rowTo   = row[table[DMBTimePeriod.Expressions.to]]
        return DMBTimePeriod(
            dbConnection:   connection,
            id:             row[table[DMBTimePeriod.Expressions.id]],
            from:           {rowFrom != nil ? formatter.dateFromString(rowFrom!):nil}(),
            to:             {rowTo != nil ? formatter.dateFromString(rowTo!):nil}())
    }
    
    static func rowToNotion(row: SQLite.Row, connection: Connection) -> DMBMonumentNotion {
        return DMBMonumentNotion(
            dbConnection:   connection,
            id:             row[DMBMonumentNotion.Expressions.id],
            name:           row[DMBMonumentNotion.Expressions.name])
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
}