//
//  DMBLocation.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 19.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation
import SQLite

/// Kapselt die Datenbank-Entität "address"
/// Liefert Ortsdaten zu bestimmten Denkmälern (Straße, Hausnummer, Longitude, Latitude)
struct DMBLocation {
    struct Expressions {
        static let id = Expression<Int?>(DMBAttribut.id)
        static let lat = Expression<Double?>(DMBAttribut.lat)
        static let long = Expression<Double?>(DMBAttribut.long)
        static let street = Expression<String?>(DMBAttribut.street)
        static let nr = Expression<String?>(DMBAttribut.nr)
    }
    private let id  :Int?
    private let lat :Double?
    private let long:Double?
    private let street: String?
    private let nr: String?
    init(id:Int?,lat:Double?,long:Double?,street:String?,nr:String?) {
        self.id     = id
        self.lat    = lat
        self.long   = long
        self.street = street
        self.nr     = nr
    }
    func getLat()->Double?{
        return lat
    }
    func getLong()->Double?{
        return long
    }
    func getStreet()->String?{
        return street
    }
    func getNr()->String?{
        return nr
    }
    
    /// Convenient Methode zur Ausgabe in der Console
    func printIt() {
        print("\nAddress")
        print("=======")
        print("id:         \(id)")
        print("lat:        \(lat)")
        print("long:       \(long)")
        print("street:     \(street)")
        print("nr:         \(nr)")
    }
}