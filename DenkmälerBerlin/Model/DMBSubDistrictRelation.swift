//
//  DMBSubDistrictRelation.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 21.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation
import SQLite

struct DMBSubDistrictRelation {
    struct Expressions {
        static let id         = Expression<Int?>(DMBAttribut.id)
        static let subDistrictId = Expression<Int?>(DMBAttribut.sub_district_id)
        static let monumentId = Expression<Int?>(DMBAttribut.monument_id)
    }
}
