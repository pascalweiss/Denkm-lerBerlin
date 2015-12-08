//
//  DMBNotionsRelation.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 21.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation
import SQLite
struct DMBNotionsRelation {
    struct Expressions {
        static let id               = Expression<Int?>(DMBAttribut.id)
        static let monumentNotionId = Expression<Int?>(DMBAttribut.monumentNotionId)
        static let monumentId       = Expression<Int?>(DMBAttribut.monumentId)
    }
}