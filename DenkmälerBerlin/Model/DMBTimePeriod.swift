//
//  DMBTimePeriod.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 19.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation

import Foundation
import SQLite
class DMBTimePeriod: DMBEntity {
    struct Expressions {
        static let id         = Expression<Int?>(DMBAttribut.id)
        static let from       = Expression<String?>(DMBAttribut.beginning)
        static let to         = Expression<String?>(DMBAttribut.ending)
        static let monumentId = Expression<Int?>(DMBAttribut.monument_id)
    }
    
    private let id:Int?
    private let from:NSDate?
    private let to:NSDate?
    private let monumentId:Int?
    
    init(dbConnection: Connection, id: Int?, from:NSDate?, to:NSDate?, monumentId:Int?) {
        self.id   = id
        self.from = from
        self.to   = to
        self.monumentId = monumentId
        super.init(dbConnection: dbConnection)
    }
    func getFrom()->NSDate? {
        return from
    }
    func getTo()->NSDate? {
        return to
    }
    
    func getAllMonuments()->[DMBMonument] {
        assert(false, "getAllMonuments() not implemented yet. I will do if required")
        return []
    }
    
    func printIt(){
        print("\nDMBTimePeriod")
        print("=============")
        print("id:              \(id)")
        print("from:            \(from)")
        print("to:              \(to)")
        print("monumentId:      \(monumentId)")
    }
}