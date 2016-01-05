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
    struct Expressions {
        static let id   = Expression<Int?>   (DMBAttribut.id)
        static let name = Expression<String?>(DMBAttribut.name)
    }
    func getName()->String {
        return "Pascal Weiß"
    }
    func getType()->String {
        return "Baudenkmal"
    }

}