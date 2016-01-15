//
//  DMBParticipant.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 19.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation
import SQLite

/// Repräsentiert die Datenbank-Entität "participant".
/// Liefert Informationen zu bestimmten Personen, die z.B. als Architekten beim Bau von Denkmälern involviert waren.
struct DMBParticipant {
    private let id:Int?
    private let name:String?
    private let dbConnection: Connection
    struct Expressions {
        static let id   = Expression<Int?>   (DMBAttribut.id)
        static let name = Expression<String?>(DMBAttribut.name)
    }
    
    init(connection: Connection, id: Int?, name: String?) {
        self.dbConnection = connection
        self.id = id
        self.name = name
    }
    
    func getName()->String? {
        return name
    }
    
    /// Convenient Methode zur Ausgabe in der Console
    func printIt(){
        print("\nDMBParticipant")
        print("===============")
        print("id:              \(id)")
        print("name:            \(name)")
    }
}