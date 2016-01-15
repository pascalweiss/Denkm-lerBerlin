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
    let searchKeys = [DMBSearchKey.byName, DMBSearchKey.byLocation, DMBSearchKey.byParticipant, DMBSearchKey.byNotion]
    var filteredData: [ [(key: String, array: [DMBMonument])] ] = []
    var minMaxResultNumber: (min: Int, max: Int)

    init(searchText: String, minMaxResultNumber: (Int, Int)) {
        self.searchText = searchText
        self.filteredData = Array(count: 4, repeatedValue: Array<(key: String, array: [DMBMonument])>())
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
        
        
        for j in 0..<searchKeys.count {
            if self.cancelled {
                return
            }
            
            for var i = 0; i < filteredMonuments[searchKeys[j]]!.count && filteredMonuments[searchKeys[j]]![i].0 > 0.2 && i < 50; i++ {
                
                if i <= minMaxResultNumber.max && j < 2 {
                    let monument = filteredMonuments[searchKeys[j]]![i].1
                    filteredData[j].append((monument.getName()!, [monument]))
                }
                
                
                if self.cancelled {
                    return
                }
                
                if searchKeys[j] == DMBSearchKey.byParticipant {
                    filteredMonuments[DMBSearchKey.byParticipant]![i].1.getParticipants().forEach { p in
                        let name = p.getName()
                        var foundAmmount = -1
                        
                        
                        for index in 0..<filteredData[j].count {
                            if filteredData[j][index].key == name {
                                foundAmmount = index
                                break;
                            }
                        }
                        
                        if foundAmmount > -1 {
                            filteredData[j][foundAmmount].array.append(filteredMonuments[DMBSearchKey.byParticipant]![i].1)
                        } else {
                            if filteredData[j].count <= minMaxResultNumber.max {
                                filteredData[j].append((name!, [filteredMonuments[DMBSearchKey.byParticipant]![i].1]))
                            }
                            
                        }
                    }
                }
                
                if self.cancelled {
                    return
                }
                
                
                
                if searchKeys[j] == DMBSearchKey.byNotion {
                    filteredMonuments[DMBSearchKey.byNotion]![i].1.getNotions().forEach { p in
                        let name = p.getName()
                        var foundAmmount = -1
                        
                        
                        for index in 0..<filteredData[j].count {
                            if filteredData[j][index].key == name {
                                foundAmmount = index
                                break;
                            }
                        }
                        
                        if foundAmmount > -1 {
                            filteredData[j][foundAmmount].array.append(filteredMonuments[DMBSearchKey.byNotion]![i].1)
                        } else {
                            if filteredData[j].count <= minMaxResultNumber.max {
                                filteredData[j].append((name!, [filteredMonuments[DMBSearchKey.byNotion]![i].1]))
                            }
                            
                        }
                        
                    }
                }
            }
            
        }

    }
}