//
//  Denkma_lerBerlinTests.swift
//  DenkmälerBerlinTests
//
//  Created by Pascal Weiß on 11.10.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import XCTest
@testable import Denkma_lerBerlin

class Denkma_lerBerlinTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSearch_B() {
        let searchS = "\'B\'"
        print("\nSearching for " + searchS + "...\n")
        self.measureBlock {
            DMBModel.sharedInstance.searchMonuments(searchS)
        }
    }
    
    func testSearch_Brandenburg() {
        let searchS = "\'Brandenburg\'"
        print("\nSearching for " + searchS + "...\n")
        self.measureBlock {
            DMBModel.sharedInstance.searchMonuments(searchS)
        }
    }
    
    func testSearch_Brandenburg_Schiller_Tor_Tor() {
        let searchS = "\'Brandenburg Schiller Tor Tor\'"
        print("\nSearching for " + searchS + "...\n")
        self.measureBlock {
            DMBModel.sharedInstance.searchMonuments(searchS)
        }
    }
    
}
