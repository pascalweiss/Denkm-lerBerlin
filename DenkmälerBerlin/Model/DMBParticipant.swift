//
//  DMBParticipant.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 19.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation

/// Repräsentiert die Datenbank-Entität "participant".
/// Liefert Informationen zu bestimmten Personen, die z.B. als Architekten beim Bau von Denkmälern involviert waren.
class DMBParticipant: DMBEntity {
    func getName()->String {
        return "Pascal Weiß"
    }
    func getType()->String {
        return "Baudenkmal"
    }
    /// Convenient Methode zur Ausgabe in der Console
    func getMonuments()->[DMBMonument] {
        return []
    }
}