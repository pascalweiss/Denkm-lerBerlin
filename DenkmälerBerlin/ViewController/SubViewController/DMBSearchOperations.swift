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
    var minMaxResultNumber: (Int, Int)

    init(searchText: String, minMaxResultNumber: (Int, Int)) {
        self.searchText = searchText
        self.filteredData = Array(count: 5, repeatedValue: Array<DMBMonument>())
        self.minMaxResultNumber = minMaxResultNumber
    }
    
    override func main() {

        if self.cancelled {
            return
        }
        
        var filteredMonuments: [String:[(Double,DMBMonument)]] = DMBModel.sharedInstance.searchMonuments(searchText)
        
        if self.cancelled {
            return
        }
        
        let searchKeys = [DMBSearchKey.byName, DMBSearchKey.byLocation, DMBSearchKey.byParticipant, DMBSearchKey.byNotion]
        
        for j in 0..<searchKeys.count {
            if self.cancelled {
                return
            }
            
            for var i = 0; i < filteredMonuments[searchKeys[j]]!.count && i < minMaxResultNumber.1; i++ {
                if filteredMonuments[searchKeys[j]]![i].0 > 0.2 {
                    filteredData[j].append(filteredMonuments[searchKeys[j]]![i].1)
                }
            }
        }
        
        

    }
}