//
//  DMBDummyData.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 19.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation
import SQLite

struct DMBDummyData {
    static func createDummyData(dbConnection: Connection) {
        
        func insertMonumentNotion() {
            let monumentNotion = Table(DMBTable.monument_notion)
            let id = Expression<Int64>(DMBAttribut.id)
            let name = Expression<String>(DMBAttribut.name)
            var inserts = [Insert]()
            inserts.append(monumentNotion.insert(id <- 300, name <- "Alter Steinhaufen"))
            inserts.append(monumentNotion.insert(id <- 301, name <- "Torbogen"))
            inserts.forEach({try! dbConnection.run($0)})
        }
        func insertMonumentNotionRel() {
            let monumentNotionRel = Table(DMBTable.monument_notion_rel)
            let id = Expression<Int64>(DMBAttribut.id)
            let monumentNotionId = Expression<Int64>(DMBAttribut.monument_notion_id)
            let monumentId = Expression<Int64>(DMBAttribut.monument_id)
            var inserts = [Insert]()
            inserts.append(monumentNotionRel.insert(id <- 400, monumentNotionId <- 300, monumentId <- 001))
            inserts.append(monumentNotionRel.insert(id <- 401, monumentNotionId <- 301, monumentId <- 000))
        }
        
        func insertTypes() {
            let types = Table(DMBTable.type)
            let id = Expression<Int64>(DMBAttribut.id)
            let name = Expression<String>(DMBAttribut.name)
            var inserts = [Insert]()
            inserts.append(types.insert(id <- 200, name <- "Baudenkmal"))
            inserts.forEach{try! dbConnection.run($0)}
        }
        
        func insertDistricts() {
            let districts = Table(DMBTable.district)
            let id = Expression<Int64>(DMBAttribut.id)
            let name = Expression<String>(DMBAttribut.name)
            var inserts = [Insert]()
            inserts.append(districts.insert(id <- 600, name <- "Mitte"))
            inserts.append(districts.insert(id <- 601, name <- "Tempelhof"))
            inserts.forEach({try! dbConnection.run($0)})
        }
        
        func insertSubDistricts() {
            let subDistrict = Table(DMBTable.sub_district)
            let id = Expression<Int64>(DMBAttribut.id)
            let name = Expression<String>(DMBAttribut.name)
            var inserts = [Insert]()
            inserts.append(subDistrict.insert(id <- 800, name <- "Mitte"))
            inserts.append(subDistrict.insert(id <- 801, name <- "Mariendorf"))
            inserts.forEach({try! dbConnection.run($0)})
        }
        
        func insertMonuments() {
            let monuments = Table(DMBTable.monument)
            let id      = Expression<Int64>(DMBAttribut.id)
            let name    = Expression<String>(DMBAttribut.name)
            let objNr   = Expression<String>(DMBAttribut.obj_nr)
            let descr   = Expression<String>(DMBAttribut.descr)
            let typeId  = Expression<Int64>(DMBAttribut.type_id)
            var inserts = [Insert]()
            inserts.append(monuments.insert(id <- 000, name <- "Brandenburger Tor", objNr <- "09038476", descr <- "Lorem ipsum dolor sit", typeId <- 200))
            inserts.append(monuments.insert(id <- 001, name <- "Pascals Schloss", objNr <- "09038477", descr <- "Lorem ipsum dolor sittich", typeId <- 200))
            inserts.forEach{try! dbConnection.run($0)}
            print(NSBundle.mainBundle().pathForResource("DMBsqlite_v2", ofType: "db"))
        }
        func insertAddresses() {
            let addresses     = Table(DMBTable.address)
            let id          = Expression<Int64>(DMBAttribut.id)
            let lat         = Expression<Double>(DMBAttribut.lat)
            let long        = Expression<Double>(DMBAttribut.long)
            let street      = Expression<String>(DMBAttribut.street)
            let nr          = Expression<String>("nr")
            let monumentId  = Expression<Int64>(DMBAttribut.monument_id)
            var inserts = [Insert]()
            inserts.append(addresses.insert(id <- 100, lat <- 52.5243700, long <- 13.4105300, street <- "Brandenburgertorstraße", nr <- "27a", monumentId <- 000))
            inserts.append(addresses.insert(id <- 101, lat <- 52.5243700, long <- 13.4205300, street <- "Pascalstraße", nr <- "42", monumentId <- 001))
            inserts.forEach{try! dbConnection.run($0)}
        }
        func insertDates() {
            let datings = Table(DMBTable.dating)
            let id = Expression<Int64>(DMBAttribut.id)
            let beginning = Expression<String>(DMBAttribut.beginning)
            let ending = Expression<String>(DMBAttribut.ending)
            let monumentId = Expression<Int64>(DMBAttribut.monument_id)
            var inserts = [Insert]()
            inserts.append(datings.insert(id <- 500, beginning <- "1919-11-11", ending <- "1920-11-11", monumentId <- 000))
            inserts.append(datings.insert(id <- 501, beginning <- "1953-11-11", monumentId <- 001))
            inserts.forEach({try! dbConnection.run($0)})
        }
        func insertDistrictRels() {
            let districtRel = Table(DMBTable.district_rel)
            let id = Expression<Int64>(DMBAttribut.id)
            let districtId = Expression<Int64>(DMBAttribut.district_id)
            let monumentId = Expression<Int64>(DMBAttribut.monument_id)
            var inserts = [Insert]()
            inserts.append(districtRel.insert(id <- 700, districtId <- 600, monumentId <- 000))
            inserts.append(districtRel.insert(id <- 701, districtId <- 601, monumentId <- 001))
            inserts.forEach({try! dbConnection.run($0)})
        }
        
        func insertSubDistrictRels() {
            let subDistrictRel = Table(DMBTable.sub_district_rel)
            let id = Expression<Int64>(DMBAttribut.id)
            let subDistrictId = Expression<Int64>(DMBAttribut.sub_district_id)
            let monumentId = Expression<Int64>(DMBAttribut.monument_id)
            var inserts = [Insert]()
            inserts.append(subDistrictRel.insert(id <- 900, subDistrictId <- 800, monumentId <- 000))
            inserts.append(subDistrictRel.insert(id <- 901, subDistrictId <- 801, monumentId <- 001))
            inserts.forEach({try! dbConnection.run($0)})
        }
        insertDistricts()
        insertSubDistricts()
        insertMonumentNotion()
        insertMonumentNotionRel()
        insertTypes()
        insertMonuments()
        insertDistrictRels()
        insertSubDistrictRels()
        insertAddresses()
        insertDates()
    }
}