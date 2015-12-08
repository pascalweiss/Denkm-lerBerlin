//
//  DMBAddressRelation.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 07.12.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation
import SQLite
struct DMBAddressRelation {
    
    struct Expressions {
        static let id   = Expression<Int?>(DMBAttribut.id)
        static let monumentId = Expression<Int?>(DMBAttribut.monumentId)
        static let addressId = Expression<Int?>(DMBAttribut.addressId)
    }
}