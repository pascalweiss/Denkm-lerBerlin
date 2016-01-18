//
//  DMBPictureURL.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 12.01.16.
//  Copyright © 2016 HTWBerlin. All rights reserved.
//

import Foundation
import SQLite

/// Kapselt die Datenbank-Entität "address"
/// Liefert Ortsdaten zu bestimmten Denkmälern (Straße, Hausnummer, Longitude, Latitude)
struct DMBPictureURL {
    struct Expressions {
        static let id = Expression<Int?>(DMBAttribut.id)
        static let monumentId = Expression<Int?>(DMBAttribut.monumentId)
        static let url = Expression<String?>(DMBAttribut.url)
    }
    private let id          :Int?
    private let monumentId  :Int?
    private let url         :String?
    
    init(id:Int?,monumentId:Int?, url:String?) {
        self.id         = id
        self.monumentId = monumentId
        self.url        = url
    }
    
    func getURL()->String?{
        return url
    }

    
    /// Convenient Methode zur Ausgabe in der Console
    func printIt() {
        print("\nDMBPictureURL")
        print("=======")
        print("id:         \(id)")
        print("monumentId: \(monumentId)")
        print("url:        \(url)")

    }
}