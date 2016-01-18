//  FBAnnotationCluster.swift
//  FBAnnotationClusteringSwift
//
//  Created by Robert Chen on 4/2/15.
//  Copyright (c) 2015 Robert Chen. All rights reserved.
//
//  Edited by Chris to DenkmalAnnotationCluster.swift
//
//
//  Copyright © 2015 HTWBerlin. All rights reserved.

import Foundation
import MapKit

class DenkmalAnnotationCluster : NSObject , MKAnnotation {
    
    var coordinate = CLLocationCoordinate2D()
    
    var title:String? = "cluster"
    var subtitle:String? = nil
    
    
    var countOfAnnotationTyps = [String:Int]()
    
    var annotations:[MKAnnotation] = []
    
    
    
    func getMKCoordinateRegionForCluster() -> MKCoordinateRegion {
        return MKCoordinateRegion(center: getCenterCoordOfCluster(), span: getClusterSpan())
    }
    
    
    func getCenterCoordOfCluster() -> CLLocationCoordinate2D {
        var latSum: Double = 0.0
        var lonSum: Double = 0.0
        for annotation in annotations {
            latSum = latSum + annotation.coordinate.latitude
            lonSum = lonSum + annotation.coordinate.longitude
        }
        return CLLocationCoordinate2D(latitude: (latSum / Double(annotations.count)), longitude: (lonSum / Double(annotations.count)))
    }
    
    func getClusterSpan() -> MKCoordinateSpan {
        var largestEWSpan: Double = 0.0
        var largestNSSpan: Double = 0.0
        
        for(var i = 0; i < annotations.count - 2; i++) {
            let ewSpan = abs(annotations[i].coordinate.longitude - annotations[i + 1].coordinate.longitude)
            let nsSpan = abs(annotations[i].coordinate.latitude - annotations[i + 1].coordinate.latitude)
            if(ewSpan > largestEWSpan) {
                largestEWSpan = ewSpan
            }
            if(nsSpan > largestNSSpan) {
                largestNSSpan = nsSpan
            }
        }
        print("latitudeDelta: \(largestEWSpan)")
        print("longitudeDelta: \(largestNSSpan)")

        return MKCoordinateSpan(latitudeDelta: largestEWSpan, longitudeDelta: largestNSSpan)
    }
}

