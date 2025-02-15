//
//  DMBDrawOperations.swift
//  DenkmälerBerlin
//
//  Created by Christian Loell on 18/01/16.
//  Copyright © 2016 HTWBerlin. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PendingDrawOperations {
    lazy var drawsInProgress: [NSOperation] = [NSOperation]()
    lazy var drawQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Draw queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}

class GetMonumentsForArea : NSOperation {
    
    var mapArea: MKCoordinateRegion
    var annotationsFromDb: [DMBDenkmalMapAnnotation]
    
    init(mapArea: MKCoordinateRegion) {
        self.mapArea = mapArea
        self.annotationsFromDb = []
    }
    
    override func main() {
    
        if self.cancelled {
            return
        }
        
        let monuments:[DMBMonument] = DMBModel.sharedInstance.getMonuments(mapArea)
        if self.cancelled {
            return
        }
        
        for monument in monuments {
            if self.cancelled {
                return
            }
            
            let address = monument.getAddress()
            let annotation = DMBDenkmalMapAnnotation(title: monument.getName()!, type: (monument.getType()?.getName())!, coordinate: CLLocationCoordinate2D(latitude: address.getLat()!, longitude: address.getLong()!), monument: monument)
            
            var street = address.getStreet()
            street = street != nil ? street : ""
            var number = address.getNr()
            number = number != nil ? number : ""
            annotation.subtitle = street! + " " + number!
            
            annotationsFromDb.append(annotation)
            
        }
        
    }
}

