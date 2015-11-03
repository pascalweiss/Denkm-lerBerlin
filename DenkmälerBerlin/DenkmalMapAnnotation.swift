//
//  DenkmalMapAnnotation.swift
//  DenkmälerBerlin
//
//  Created by Max on 31.10.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import UIKit
import MapKit

class DenkmalMapAnnotation: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var latitude: Double
    var longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
