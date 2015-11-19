//
//  DMBEntity.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 19.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation
import SQLite

class DMBEntity {
    internal let dbConnection: Connection

    init(dbConnection: Connection) {
        self.dbConnection = dbConnection
    }
}