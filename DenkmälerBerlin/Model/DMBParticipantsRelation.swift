//
//  DMBParticipantsRelation.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 12.12.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//


import Foundation
import SQLite

/// Repräsentiert die Datenbank-Entität "monument_notion_rel".
/// Ermöglicht eine n:n Beziehung zwischen Denkmälern und und Objekttypen
struct DMBParticipantsRelation {
    struct Expressions {
        static let id                   = Expression<Int?>(DMBAttribut.id)
        static let participantId        = Expression<Int?>(DMBAttribut.participantId)
        static let participantTypeId    = Expression<Int?>(DMBAttribut.participantTypeId)
        static let monumentId           = Expression<Int?>(DMBAttribut.monumentId)
    }
}