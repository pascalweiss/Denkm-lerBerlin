//
//  DMBSubDistrictRelation.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 21.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation
import SQLite

/// Ermöglicht eine n:n Beziehung zwischen Denkmälern und Ortsteilen
struct DMBSubDistrictRelation {
    struct Expressions {
        static let id         = Expression<Int?>(DMBAttribut.id)
        static let subDistrictId = Expression<Int?>(DMBAttribut.subDistrictId)
        static let monumentId = Expression<Int?>(DMBAttribut.monumentId)
    }
}
