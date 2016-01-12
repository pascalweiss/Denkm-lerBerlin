//
//  DMBSearchOperations.swift
//  DenkmälerBerlin
//
//  Created by Max on 07.01.16.
//  Copyright © 2016 HTWBerlin. All rights reserved.
//

import Foundation
import UIKit

class PendingOperations {
    lazy var searchsInProgress = [Int:NSOperation]()
    lazy var searchQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Search queue"
        queue.maxConcurrentOperationCount = 5
        return queue
    }()
}

class SearchMonument : NSOperation {
    
    let searchText: String
    var filteredData: [[DMBMonument]]

    init(searchText: String) {
        self.searchText = searchText
        self.filteredData = []
    }
    
    override func main() {

        if self.cancelled {
            return
        }
        
        var filteredMonuments: [String:[(Double,DMBMonument)]] = DMBModel.sharedInstance.searchMonuments(searchText)
        
        if self.cancelled {
            return
        }
        
        /*// Filter by Name
        for var i = 0; i < filteredMonuments[DMBSearchKey.byName]!.count && i < 5; i++ {
            filteredData.append([])
            filteredData[0].append(filteredMonuments[DMBSearchKey.byName]![i].1)
        }
        
        if self.cancelled {
            return
        }
        
        for var i = 0; i < filteredMonuments[DMBSearchKey.byLocation]!.count && i < 5; i++ {
            filteredData.append([])
            filteredData[1].append(filteredMonuments[DMBSearchKey.byLocation]![i].1)
        }*/
        
        let searchKeys = [DMBSearchKey.byName, DMBSearchKey.byLocation, DMBSearchKey.byParticipant, DMBSearchKey.byNotion]
        
        for j in 0..<searchKeys.count {
            if self.cancelled {
                return
            }
            
            for var i = 0; i < filteredMonuments[searchKeys[j]]!.count && i < 5; i++ {
                filteredData.append([])
                if filteredMonuments[searchKeys[j]] != nil {
                    filteredData[j].append(filteredMonuments[searchKeys[j]]![i].1)
                }
            }
        }
        
        

    }
}