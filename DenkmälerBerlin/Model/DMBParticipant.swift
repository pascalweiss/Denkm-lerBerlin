//
//  DMBParticipant.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 19.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation

class DMBParticipant: DMBEntity {
    func getName()->String {
        return "Pascal Weiß"
    }
    func getType()->String {
        return "Baudenkmal"
    }
    func getMonuments()->[DMBMonument] {
        return []
    }
}