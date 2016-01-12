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
    let Baudenkmal = true
    let Parkdenkmal = true
    
    // Time period
    let from:NSDate
    let to = NSDate()
    
    // Districts
    let prenzlauerBerg = true
    // TODO
    
    init() {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.FullStyle
        formatter.dateFormat = "yyyyMMdd"
        from = formatter.dateFromString("18000101")!
    }
    
    func setStandardFrom() {
    }
}