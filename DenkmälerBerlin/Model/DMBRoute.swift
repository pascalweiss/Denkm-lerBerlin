//
//  DMBRoute.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 19.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation

/// Repräsentiert die Datenbank-Entität "route". 
/// Repräsentiert eine Route, die dem User vorgeschlagen werden sollen. 
class DMBRoute: DMBEntity {
    func getDescription()->String {
        return "this is a dummy route"
    }
    func getName()->String {
        return "dummyRoute"
    }
    func getLength()->String {
        return "15km"
    }
    func getMonuments()->[DMBMonument]{
        return []
    }
}