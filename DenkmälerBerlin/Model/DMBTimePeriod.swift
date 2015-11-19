//
//  DMBTimePeriod.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 19.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation

struct DMBTimePeriod {
    private let from: NSDate
    private let to:   NSDate
    
    init(from:NSDate, to:NSDate){
        self.from = from
        self.to   = to
    }
    
    func getFrom()->NSDate{
        return self.from
    }
    func getTo()->  NSDate{
        return self.to
    }
}