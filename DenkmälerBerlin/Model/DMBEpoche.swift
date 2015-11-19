//
//  DMBEpoche.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 19.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation

struct DMBEpoche {
    let name:String
    let timePeriod: DMBTimePeriod
    init (name:String,timePeriod:DMBTimePeriod) {
        self.name       = name
        self.timePeriod = timePeriod
    }
    func getName()->String {
        return name
    }
    func getTimePeriod()->DMBTimePeriod{
        return timePeriod
    }
}