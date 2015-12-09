//
//  DMBDistrictRelation.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 21.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation
import SQLite

/// Repräsentiert die Datenbank-Entität "district_rel".
/// Ermöglicht eine n:n Beziehung zwischen Denkmälern und Bezirken
struct DMBDistrictRelation {
    struct Expressions {
        static let id         = Expression<Int?>(DMBAttribut.id)
        static let districtId = Expression<Int?>(DMBAttribut.districtId)
        static let monumentId = Expression<Int?>(DMBAttribut.monumentId)
    }
}
