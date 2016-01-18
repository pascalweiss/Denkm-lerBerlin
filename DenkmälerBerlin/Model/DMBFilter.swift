//
//  DMBFilter.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 18.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//


import UIKit

struct DMBFilter {
    
    // Monument Types
    var ensemble                    = true
    var ensembleteil                = true
    var gesamtanlage                = true
    var baudenkmal                  = true
    var gartendenkmal               = true
    var bodendenkmal                = true
    
    // Districts
    var charlottenburgWilmersdorf   = true
    var steglitzZehlendorf          = true
    var spandau                     = true
    var friedrichshainKreuzberg     = true
    var tempelhofSchöneberg         = true
    var mitte                       = true
    var neukölln                    = true
    var lichtenberg                 = true
    var marzahnHellersdorf          = true
    var pankow                      = true
    var reinickendorf               = true
    var treptowKöpenick             = true
    
    // Time period
    var dateEnabled                 = true
    var from:NSDate
    var to = NSDate()
    
    init() {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.FullStyle
        formatter.dateFormat = "yyyyMMdd"
        from = formatter.dateFromString("10010101")!
    }
}