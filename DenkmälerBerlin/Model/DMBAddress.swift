//
//  DMBAddress.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 19.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation

struct DMBAddress {
    private let lat :Float
    private let long:Float
    private let street: String
    private let nr: String
    init(lat:Float,long:Float,street:String,nr:String) {
        self.lat    = lat
        self.long   = long
        self.street = street
        self.nr     = nr
    }
    func getLat()->Float{
        return lat
    }
    func getLong()->Float{
        return long
    }
    func getStreet()->String{
        return street
    }
    func getNr()->String{
        return nr
    }
}