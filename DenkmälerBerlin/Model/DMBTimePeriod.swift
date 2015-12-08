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
    }
    
    private let id:Int?
    private let from:NSDate?
    private let to:NSDate?
    
    init(dbConnection: Connection, id: Int?, from:NSDate?, to:NSDate?) {
        self.id   = id
        self.from = from
        self.to   = to
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
    }
}