//
//  DMBMonumentNotion.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 21.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation

import Foundation
import SQLite

/// Repräsentiert die Datenbank-Entität "monument_notion"
/// Liefert den "ObjektTyp" (z.B. "Brücke", "Brunnen") zu bestimmten Denkmälern
class DMBNotion: DMBEntity {
    
    struct Expressions {
        static let id   = Expression<Int?>(DMBAttribut.id)
        static let name = Expression<String?>(DMBAttribut.name)
    }
    
    private let id:Int?
    private let name:String?
    
    init(dbConnection: Connection, id: Int?, name:String?) {
        self.id = id
        self.name = name
        super.init(dbConnection: dbConnection)
    }
    func getName()->String? {
        return name
    }
    
    func getAllMonuments()->[DMBMonument] {
        assert(false, "getAllMonuments() not implemented yet. I will do if required")
        return []
    }
    
    /// Convenient Methode zur Ausgabe in der Console
    func printIt(){
        print("\nDMBMonumentNotion")
        print("===========")
        print("id:              \(id)")
        print("name:            \(name)")
    }
}