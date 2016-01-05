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
            let monumentNotion = Table(DMBTable.monumentNotion)
            let id = Expression<Int64>(DMBAttribut.id)
            let name = Expression<String>(DMBAttribut.name)
            var inserts = [Insert]()
            inserts.append(monumentNotion.insert(id <- 300, name <- "Alter Steinhaufen"))
            inserts.append(monumentNotion.insert(id <- 301, name <- "Torbogen"))
            inserts.forEach({try! dbConnection.run($0)})
        }
        func insertMonumentNotionRel() {
            let monumentNotionRel = Table(DMBTable.monumentNotionRel)
            let id = Expression<Int64>(DMBAttribut.id)
            let monumentNotionId = Expression<Int64>(DMBAttribut.monumentNotionId)
            let monumentId = Expression<Int64>(DMBAttribut.monumentId)
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
            inserts.append(districts.insert(id <- 601, name <- "Tempelhof-Schöneberg"))
            inserts.forEach({try! dbConnection.run($0)})
        }
        
        func insertSubDistricts() {
            let subDistrict = Table(DMBTable.subDistrict)
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
            let objNr   = Expression<String>(DMBAttribut.objNr)
            let descr   = Expression<String>(DMBAttribut.descr)
            let typeId  = Expression<Int64>(DMBAttribut.typeId)
            let datingId  = Expression<Int64>(DMBAttribut.datingId)
            var inserts = [Insert]()
            inserts.append(monuments.insert(id <- 000, name <- "Brandenburger Tor", objNr <- "09038476", descr <- "Lorem ipsum dolor sit", typeId <- 200, datingId <- 500))
            inserts.append(monuments.insert(id <- 001, name <- "Pascals Schloss", objNr <- "09038477", descr <- "Lorem ipsum dolor sittich", typeId <- 200, datingId <- 501))
            inserts.forEach{try! dbConnection.run($0)}
        }
        func insertAddresses() {
            let addresses     = Table(DMBTable.address)
            let id          = Expression<Int64>(DMBAttribut.id)
            let lat         = Expression<Double>(DMBAttribut.lat)
            let long        = Expression<Double>(DMBAttribut.long)
            let street      = Expression<String>(DMBAttribut.street)
            let nr          = Expression<String>("nr")
            var inserts = [Insert]()
            inserts.append(addresses.insert(id <- 100, lat <- 52.5243700, long <- 13.4105300, street <- "Brandenburgertorstraße", nr <- "27a"))
            inserts.append(addresses.insert(id <- 101, lat <- 52.5243700, long <- 13.4205300, street <- "Pascalstraße", nr <- "42"))
            inserts.forEach{try! dbConnection.run($0)}
        }
        func insertDates() {
            let datings = Table(DMBTable.dating)
            let id = Expression<Int64>(DMBAttribut.id)
            let beginning = Expression<String>(DMBAttribut.beginning)
            let ending = Expression<String>(DMBAttribut.ending)
            var inserts = [Insert]()
            inserts.append(datings.insert(id <- 500, beginning <- "1919-11-11", ending <- "1920-11-11"))
            inserts.append(datings.insert(id <- 501, beginning <- "1953-11-11"))
            inserts.forEach({try! dbConnection.run($0)})
        }
        func insertDistrictRels() {
            let districtRel = Table(DMBTable.districtRel)
            let id = Expression<Int64>(DMBAttribut.id)
            let districtId = Expression<Int64>(DMBAttribut.districtId)
            let monumentId = Expression<Int64>(DMBAttribut.monumentId)
            var inserts = [Insert]()
            inserts.append(districtRel.insert(id <- 700, districtId <- 600, monumentId <- 000))
            inserts.append(districtRel.insert(id <- 701, districtId <- 601, monumentId <- 001))
            inserts.forEach({try! dbConnection.run($0)})
        }
        func insertAddressRels(){
            let addressRel = Table(DMBTable.addressRel)
            let id = Expression<Int64>(DMBAttribut.id)
            let monumentId = Expression<Int64>(DMBAttribut.monumentId)
            let addressId = Expression<Int64>(DMBAttribut.addressId)
            var inserts = [Insert]()
            inserts.append(addressRel.insert(id <- 1000, monumentId <- 000, addressId <- 100))
            inserts.append(addressRel.insert(id <- 1001, monumentId <- 001, addressId <- 101))
            inserts.forEach({try! dbConnection.run($0)})
        }
        func insertSubDistrictRels() {
            let subDistrictRel = Table(DMBTable.subDistrictRel)
            let id = Expression<Int64>(DMBAttribut.id)
            let subDistrictId = Expression<Int64>(DMBAttribut.subDistrictId)
            let monumentId = Expression<Int64>(DMBAttribut.monumentId)
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
        insertAddressRels()
        insertDates()
    }
}