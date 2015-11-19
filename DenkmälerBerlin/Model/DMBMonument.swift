//
//  DMBMonument.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 19.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation
import UIKit

class DMBMonument: DMBEntity {
    
    // e.g. Brandenburger Tor
    func getName()->String {
        self.dbConnection
        return "wat"
    }
    func getNr()->Int {
        return 0
    }
    func getPicUrl()->NSURL? {
        return NSURL(string: "http://dummy.url.com")
    }
    func getDescription()->String{
        return "Das ist das Haus vom Nikolaus"
    }
    // e.g. Charlottenburg-Wilmersdorf
    func getDistrict()->String {
        return "Charlottenburg-Wilmersdorf"
    }
    // e.g. Charlottenburg
    func getSubDistrict()->String {
        return "Charlottenburg"
    }
    func getRoutes()->[DMBRoute] {
        return []
    }
    // e.g. Baudenkmal
    func getType()->String {
        return "Baudenkmal"
    }
    func getMonumentNotion()->String {
        return "Brücke"
    }
    func getCreationPeriod()->DMBTimePeriod {
        return DMBTimePeriod(from: NSDate(timeIntervalSince1970: 1234879), to: NSDate(timeIntervalSince1970: 237987947))
    }
    func getAddresses()->[DMBAddress]{
        return []
    }
    func getParticipants()->[DMBParticipant] {
        return []
    }
    func getLinkedMonuments()->[DMBMonument] {
        return []
    }
    func getMetaMonument()->DMBMonument? {
        return nil
    }
}

