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
        print("\nSearchstring: \'B\'...\n" +
                "====================")
        self.measureBlock {
            DMBModel.sharedInstance.searchMonuments("B")
        }
    }
    
    func testSearch_Brandenburg() {
        print("\nSearchstring: \'Brandenburg\'...\n" +
                "==============================")
        self.measureBlock {
            DMBModel.sharedInstance.searchMonuments("Brandenburg")
        }
    }
    
    func testSearch_Brandenburg_Schiller_Tor_Tor() {
        print("\nSearchstring: \'Brandenburg Schiller Tor Tor\'...\n" +
                "===============================================")
        self.measureBlock {
            DMBModel.sharedInstance.searchMonuments("Brandenburg Schiller Tor Tor")
        }
    }
}
