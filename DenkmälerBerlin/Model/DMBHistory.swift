//
//  DMBHistory.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 07.01.16.
//  Copyright © 2016 HTWBerlin. All rights reserved.
//

import Foundation
import SQLite

struct DMBHistory {
    private let searchString:String?
    private let timeIntervalSince1970:NSTimeInterval?
    struct Expressions {
        static let searchString     = Expression<String?>(DMBAttribut.searchString)
        static let timeIntSince1970 = Expression<Double?>(DMBAttribut.timeIntSince1970)
    }
    init(searchString: String?, timeIntSince1970: NSTimeInterval?) {
        self.searchString           = searchString
        self.timeIntervalSince1970  = timeIntSince1970
    }
    
    func printIt() {
        print("\nHistory Entry:\n" +
                "==============\n")
        print(String(timeIntervalSince1970) + ": " + String(searchString))
    }
}