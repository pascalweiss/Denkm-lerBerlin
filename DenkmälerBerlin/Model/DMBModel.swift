//
//  DMBModel.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 18.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation
import SQLite
import MapKit

/// Diese Klasse implementiert das Singleton-Pattern, wodruch sie nicht vom Entwickler selbst instanziiert werden muss.
/// Zugriff auf die Methoden werden - wie z.B, bei "NSUserDefaults.standardUserDefaults" - durch das statische Objekt "DMBModel.sharedInstance" gewährt.
/// Es liefert einige Methoden, mit denen Daten aus der Datenbank abgefragt werden können.
/// Z.B. können bestimmte Denkmäler anhand eines Suchstrings gesucht werden. 
/// Sämtliche Suchergebnisse sind Objekte, deren Klassen von "DMBEntity" erben. 
/// Diese haben die Fähigkeit, weitere Anfragen an die Datenbank zu stellen, wobei dann wiederum Objekte vom Typ DMBEntity zurück gegeben werden.
/// z.B. liefert ein Objekt der Klasse "DMBMonument" mit "getAddress" sämtliche Ortsdaten (Straße, Hausnummer, Longitude, Latitude) in Form eines DMBLocation-Objekts.
/// Dieses Verfahren ermöglicht einen möglichst komfortablen und effizenten Umgang mit der darunter liegenden Datenbank,
/// da sämtliche Operationen durch Methoden gekapselt werden, und gleichzeitig die benötigten Daten erst dann abgefragt werden, wenn sie benötigt werden.
/// Das Verfahren ist dem Apple eigenen Framework CoreData nachempfunden.
class DMBModel {
    
    static let sharedInstance = DMBModel()
    public var filter = DMBFilter()
    private let dbConnection: Connection
    private let debug = false
    
    private let recopyDatabase = false // true Setzt Datenbank zurück
    private let sqliteFileName = "DMBsqlite3_v8"

    private init() {
        if debug {
            print(NSBundle.mainBundle().pathForResource(sqliteFileName, ofType: "db"))
        }
        let fileManager = NSFileManager.defaultManager()
        let documentsPath: NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
        let filePath = documentsPath.stringByAppendingPathComponent("/" + sqliteFileName + ".db")
        if recopyDatabase {
            while fileManager.fileExistsAtPath(filePath) {
                print("File exists")
                try! fileManager.removeItemAtPath(filePath)}}
        if !fileManager.fileExistsAtPath(filePath) {
            let srcPath = NSBundle.mainBundle().pathForResource(sqliteFileName, ofType: "db")
            try! fileManager.copyItemAtPath(srcPath!, toPath: filePath)
        }
        self.dbConnection = try! Connection(filePath, readonly: false)
    }
    
    
    func setFilter(filter:DMBFilter) {
        self.filter=filter
    }
    
    /*
     _     _     _
    | |__ (_)___| |_ ___  _ __ _   _
    | '_ \| / __| __/ _ \| '__| | | |
    | | | | \__ \ || (_) | |  | |_| |
    |_| |_|_|___/\__\___/|_|   \__, |
                               |___/
    */
 
    func setHistoryEntry(searchString: String) {
        let history = Table(DMBTable.history)
        let searchS = Expression<String>(DMBAttribut.searchString)
        let timeInterval = Expression<Double>(DMBAttribut.timeIntSince1970)
        try! self.dbConnection.run(history.insert(searchS <- searchString, timeInterval <- NSDate().timeIntervalSince1970))
    }
    
    func getHistory() -> [DMBHistory] {
        let history = Table(DMBTable.history)
        return dbConnection
            .prepare(history)
            .map{row -> DMBHistory in
                return DMBConverter.rowToHistory(row, connection: self.dbConnection)
        }
    }
    
    func deleteHistory() {
        let history = Table(DMBTable.history)
        try! dbConnection.run(history.delete())
    }
    
    /*
     _____       _   _ _            ___                  _
    | ____|_ __ | |_(_) |_ _   _   / _ \ _   _  ___ _ __(_) ___  ___
    |  _| | '_ \| __| | __| | | | | | | | | | |/ _ \ '__| |/ _ \/ __|
    | |___| | | | |_| | |_| |_| | | |_| | |_| |  __/ |  | |  __/\__ \
    |_____|_| |_|\__|_|\__|\__, |  \__\_\\__,_|\___|_|  |_|\___||___/
                           |___/
    */
    
    func getAllParticipants()->[DMBParticipant]{
        return []
    }
    
    func getAllEpoches()->[DMBEpoche] {
        assert(false, "getAllMonuments() not implemented yet. I will do it if required")
        return []
    }
    
    /// - returns:  Sämtliche Bezirke, die in der Datenbank vermerkt sind.
    ///             Z.B. "Prenzlauer Berg", "Neukölln", etc.
    ///             Der Rückgabewert ist ein Array vom Typ DMBDistrict
    func getAllDistricts()->[DMBDistrict] {
        let districts = Table(DMBTable.district)
        return dbConnection.prepare(districts).map{row -> DMBDistrict in
            return DMBConverter.rowToDistrict(row, connection: dbConnection)
        }
    }
    
    func getAllSubDistricts()->[DMBSubDistrict] {
        assert(false, "getAllMonuments() not implemented yet. I will do it if required")
        return []
    }
    
    func getAllRoutes()->[DMBRoute] {
        assert(false, "getAllMonuments() not implemented yet. I will do it if required")
        return []
    }
    /// - returns:  Sämtliche Denkmaltypen.
    ///             Z.B.: "Baudenkmal" oder "Ensemble".
    ///             Rückgabewert ist ein Array vom Typ DMBType.
    func getAllTypes()->[DMBType] {
        let types = Table(DMBTable.type)
        return dbConnection.prepare(types).map{row -> DMBType in
            return DMBConverter.rowToType(row, connection: dbConnection)
        }
    }
    
    /// - returns:  Sämtliche Denkmäler.
    ///             Rückgabewert ist ein Array vom Typ DMBMonument.
    func getAllMonuments() -> [DMBMonument] {
        let monuments = Table(DMBTable.monument)
        return dbConnection.prepare(monuments)
            .map({row -> DMBMonument in
                return DMBConverter.rowToMonument(row, connection: dbConnection)
        })
    }
    
    /// - returns:  Sämtliche Denkmäler, die sich innerhalb der als Parameter übergebenen MKCooridnateRegion befinden.
    func getMonuments(area:MKCoordinateRegion) -> [DMBMonument]{
        let monuments  = Table(DMBTable.monument)
        let addresses  = Table(DMBTable.address)
        let addressRel = Table(DMBTable.addressRel)
        let inLongitude = area.center.longitude - area.span.longitudeDelta < DMBLocation.Expressions.long
            && DMBLocation.Expressions.long < area.center.longitude + area.span.longitudeDelta
        let inLatitude  = area.center.latitude - area.span.latitudeDelta < DMBLocation.Expressions.lat
            && DMBLocation.Expressions.lat < area.center.latitude + area.span.latitudeDelta
        return dbConnection.prepare(monuments
            .join(addressRel, on: monuments[DMBMonument.Expressions.id] == addressRel[DMBLocationRelation.Expressions.monumentId])
            .join(addresses, on: addressRel[DMBLocationRelation.Expressions.addressId] == addresses[DMBLocation.Expressions.id])
            .filter(inLongitude && inLatitude))
            .map({row -> DMBMonument in
                return DMBConverter.rowToMonument(row, connection: dbConnection, table: monuments)
        })
    }
    
    /// - parameter: Der Suchstring, so wie er vom User eingegeben wurde.
    /// - returns:  Ein Dictionary der Suchergebnisse. Jedes Suchergebnis besteht
    ///             aus einem Array aus Tupeln. Jedes Tupel enthält ein bei der Suche
    ///             gefundenes Denkmal, und dessen Ranking Wert. Die Rankingwerte ergeben 
    ///             sich aus der Anzahl der Suchergebnisse für das jeweilige Denkmal, 
    ///             und dem Grad, wie gut die jeweiligen Wörter des Suchstrings auf das 
    ///             Suchergebnis gematcht haben. Die Tupel sind anhand der Match-Werte 
    ///             absteigend sortiert.
    ///
    func searchMonuments(searchString: String) -> [String:[(Double,DMBMonument)]] {
        let tokens = createTokens(searchString)
        return [
            DMBSearchKey.byName:        rankedMonumentsByName(tokens,filtered:false),
            DMBSearchKey.byLocation:    rankedMonumentsByLocation(tokens,filtered:false),
            DMBSearchKey.byParticipant: rankedMonumentsByParticipant(tokens,filtered:false),
            DMBSearchKey.byNotion:      rankedMonumentsByNotion(tokens,filtered:false)]
    }
    
    func searchMonumentsWithFilter(searchString: String) -> [String:[(Double,DMBMonument)]] {
        let tokens = createTokens(searchString)
        return [
            DMBSearchKey.byName:        rankedMonumentsByName(tokens,filtered:true),
            DMBSearchKey.byLocation:    rankedMonumentsByLocation(tokens,filtered:true),
            DMBSearchKey.byParticipant: rankedMonumentsByParticipant(tokens,filtered:true),
            DMBSearchKey.byNotion:      rankedMonumentsByNotion(tokens,filtered:true)]
    }
    
/*
     ____            _               ___                  _
    / ___|  ___ __ _| | __ _ _ __   / _ \ _   _  ___ _ __(_) ___  ___
    \___ \ / __/ _` | |/ _` | '__| | | | | | | |/ _ \ '__| |/ _ \/ __|
     ___) | (_| (_| | | (_| | |    | |_| | |_| |  __/ |  | |  __/\__ \
    |____/ \___\__,_|_|\__,_|_|     \__\_\\__,_|\___|_|  |_|\___||___/
*/
    
    /// - returns: Das kleinste in der DB vermerkte Datum eines Denkmals
    func getMinDate() -> NSDate? {
        let datings = DMBTable.dating
        let from = DMBTimePeriod.Expressions.from.template
        let to   = DMBTimePeriod.Expressions.to.template
        let stmtFrom = dbConnection.prepare("SELECT min(\(from)) FROM \(datings)")
        let stmtTo   = dbConnection.prepare("SELECT min(\(to)) FROM \(datings)")
        let maxFrom = DMBConverter.stringToDate(stmtFrom.scalar() as! String)
        let maxTo   = DMBConverter.stringToDate(stmtTo.scalar() as! String)
        if maxTo != nil && maxFrom != nil {
            return {maxTo!.timeIntervalSinceDate(maxFrom!) > 0 ? maxFrom:maxTo}()
        }
        else if maxTo != nil {
            return maxTo
        }
        else if maxFrom != nil {
            return maxFrom
        }
        return nil
    }
    
    /// - returns: Das größte in der DB vermerkte Datum eines Denkmals
    func getMaxDate() -> NSDate? {
        let datings = DMBTable.dating
        let from = DMBTimePeriod.Expressions.from.template
        let to   = DMBTimePeriod.Expressions.to.template
        let stmtFrom = dbConnection.prepare("SELECT max(\(from)) FROM \(datings)")
        let stmtTo   = dbConnection.prepare("SELECT max(\(to)) FROM \(datings)")
        let maxFrom = DMBConverter.stringToDate(stmtFrom.scalar() as! String)
        let maxTo   = DMBConverter.stringToDate(stmtTo.scalar() as! String)
        if maxTo != nil && maxFrom != nil {
            return {maxTo!.timeIntervalSinceDate(maxFrom!) > 0 ? maxTo:maxFrom}()
        }
        else if maxTo != nil {
            return maxTo
        }
        else if maxFrom != nil {
            return maxFrom
        }
        return nil
    }
    
/*
                             _             _
     ___  ___  __ _ _ __ ___| |__     __ _| | __ _  ___
    / __|/ _ \/ _` | '__/ __| '_ \   / _` | |/ _` |/ _ \
    \__ \  __/ (_| | | | (__| | | | | (_| | | (_| | (_) |
    |___/\___|\__,_|_|  \___|_| |_|  \__,_|_|\__, |\___/
                                             |___/
*/
     /// Anhand der übergebenen Tokens werden Denkmäler anhand ihres Names gesucht.
     /// - parameter tokens: Array aus tokens. Jeder token sollte klein geschrieben sein.
     /// - returns: Array aus Tupel. Jedes Tupel besteht aus einem gefundenen Monument, 
     ///            und dessen Ranking. Die Tupel wurden bereits anhand der
     ///            Rankings absteigend sortiert.
    private func rankedMonumentsByName(tokens: [String],filtered:Bool) -> [(Double,DMBMonument)] {
        func searchMonumentsByName(token: String) -> [(Double,DMBMonument)] {
            let monuments = Table(DMBTable.monument)
            return dbConnection.prepare(getBasicQuery(filtered)
                .filter(monuments[DMBMonument.Expressions.name].lowercaseString.like(searchableString(token))))
                .map({row -> (Double,DMBMonument) in
                    var monum: DMBMonument
                    if filtered {monum = DMBConverter.rowToMonument(row, connection: dbConnection,table: monuments)}
                    else {monum = DMBConverter.rowToMonument(row, connection: dbConnection)}
                    let match = getMatch(monum.getName()!, searchString: token)     // Da das query ein Ergebnis ergeben hat,
                    // darf hier ein promise gemacht werden
                    return (match,monum)
                })
        }
        return rankMonuments(tokens.flatMap({word -> [(Double,DMBMonument)] in
            return searchMonumentsByName(word)
        }))
    }
    
    private func rankedMonumentsWithFilterByName(tokens: [String],filtered:Bool) -> [(Double,DMBMonument)] {
        func searchMonumentsByName(token: String) -> [(Double,DMBMonument)] {
            let monuments = Table(DMBTable.monument)
            return dbConnection.prepare(getBasicQuery(filtered)
                .filter(monuments[DMBMonument.Expressions.name].lowercaseString.like(searchableString(token))))
                .map({row -> (Double,DMBMonument) in
                    var monum:DMBMonument
                    if filtered {monum = DMBConverter.rowToMonument(row, connection: dbConnection,table: monuments)}
                    else {monum = DMBConverter.rowToMonument(row, connection: dbConnection)}
                    let match = getMatch(monum.getName()!, searchString: token)     // Da das query ein Ergebnis ergeben hat,
                    // darf hier ein promise gemacht werden
                    return (match,monum)
                })
        }
        return rankMonuments(tokens.flatMap({word -> [(Double,DMBMonument)] in
            return searchMonumentsByName(word)
        }))
    }
    
    
    /// Es werden Denkmäler gesucht, dessen Adresse auf die übergebenen Tokens matcht.
    /// Die Hausnummer wird nicht beachtet.
    /// - parameter tokens: Array aus tokens. Jeder token sollte klein geschrieben sein.
    /// - returns: Array aus Tupel. Jedes Tupel besteht aus einem gefundenen Monument,
    ///            und dessen Ranking. Die Tupel wurden bereits anhand der
    ///            Rankings absteigend sortiert.
    private func rankedMonumentsByLocation(tokens: [String],filtered:Bool) -> [(Double,DMBMonument)] {
        func searchMonumentsByLocation(token: String) -> [(Double,DMBMonument)] {
            let monuments   = Table(DMBTable.monument)
            let locationRel = Table(DMBTable.addressRel)
            let locations   = Table(DMBTable.address)
            return dbConnection.prepare(getBasicQuery(filtered)
                .join(locationRel, on: monuments[DMBMonument.Expressions.id] == locationRel[DMBLocationRelation.Expressions.monumentId])
                .join(locations, on: locationRel[DMBLocationRelation.Expressions.addressId] == locations[DMBLocation.Expressions.id])
                .filter(locations[DMBLocation.Expressions.street].lowercaseString.like(searchableString(token))))
                .map({row -> (Double, DMBMonument) in
                    let address = row.get(DMBLocation.Expressions.street)!          // Da das query ein Ergebnis ergeben hat,
                    // darf hier ein promise gemacht werden
                    let monum   = DMBConverter.rowToMonument(row, connection: dbConnection, table: monuments)
                    let match   = getMatch(address, searchString: token)
                    return (match, monum)
                })
        }
        return rankMonuments(tokens.flatMap({word -> [(Double,DMBMonument)] in
            return searchMonumentsByLocation(word)
        }))
    }
    
    /// Es werden Denkmäler gesucht, dessen Mitwirkende (z.b. Architekt) auf die
    /// übergebenen Tokens matched.
    /// - parameter tokens: Array aus tokens. Jeder token sollte klein geschrieben sein.
    /// - returns: Array aus Tupel. Jedes Tupel besteht aus einem gefundenen Monument,
    ///            und dessen Ranking. Die Tupel wurden bereits anhand der
    ///            Rankings absteigend sortiert.
    private func rankedMonumentsByParticipant(tokens: [String],filtered:Bool) -> [(Double, DMBMonument)] {
        func searchMonumentsByParticipant(token: String) -> [(Double, DMBMonument)] {
            let monuments       = Table(DMBTable.monument)
            let participantsRel = Table(DMBTable.participantRel)
            let participants    = Table(DMBTable.participant)
            return dbConnection.prepare(getBasicQuery(filtered)
                .join(participantsRel, on: monuments[DMBMonument.Expressions.id] == participantsRel[DMBParticipantsRelation.Expressions.monumentId])
                .join(participants, on: participantsRel[DMBParticipantsRelation.Expressions.participantId] == participants[DMBParticipant.Expressions.id])
                .filter(participants[DMBParticipant.Expressions.name].lowercaseString.like(searchableString(token))))
                .map({row -> (Double, DMBMonument) in
                    let participant = row.get(participants[DMBParticipant.Expressions.name])!       // Da das query ein Ergebnis ergeben hat,
                    // darf hier ein promise gemacht werden
                    let monum       = DMBConverter.rowToMonument(row, connection: dbConnection, table: monuments)
                    let match       = getMatch(participant, searchString: token)
                    return (match, monum)
                })
        }
        return rankMonuments(tokens.flatMap({word -> [(Double, DMBMonument)] in
            return searchMonumentsByParticipant(word)
        }))
    }
    
    /// Es werden Denkmäler gesucht, dessen objektTyp (z.B. Kirche, Brücke) auf die
    /// übergebenen Tokens matched.
    /// - parameter tokens: Array aus tokens. Jeder token sollte klein geschrieben sein.
    /// - returns: Array aus Tupel. Jedes Tupel besteht aus einem gefundenen Monument,
    ///            und dessen Ranking. Die Tupel wurden bereits anhand der
    ///            Rankings absteigend sortiert.
    private func rankedMonumentsByNotion(tokens: [String],filtered:Bool) -> [(Double, DMBMonument)] {
        func searchMonumentsByNotion(token: String) -> [(Double, DMBMonument)] {
            let monuments = Table(DMBTable.monument)
            let notionRel = Table(DMBTable.monumentNotionRel)
            let notions   = Table(DMBTable.monumentNotion)
            return dbConnection.prepare(getBasicQuery(filtered)
                .join(notionRel, on: monuments[DMBMonument.Expressions.id] == notionRel[DMBNotionsRelation.Expressions.monumentId])
                .join(notions, on: notionRel[DMBNotionsRelation.Expressions.monumentNotionId] == notions[DMBNotion.Expressions.id])
                .filter(notions[DMBNotion.Expressions.name].lowercaseString.like(searchableString(token))))
                .map({row -> (Double, DMBMonument) in
                    let notion = row.get(notions[DMBNotion.Expressions.name])!
                    let monum  = DMBConverter.rowToMonument(row, connection: dbConnection, table: monuments)
                    let match  = getMatch(notion, searchString: token)
                    return (match, monum)
                })
        }
        return rankMonuments(tokens.flatMap({word -> [(Double, DMBMonument)] in
            return searchMonumentsByNotion(word)
        }))
    }
    
    private func searchableString(string: String) -> String {
        return string + "%"
    }
    
    /// - parameter string: Der Suchstring, so, wie er vom User eingegeben wurde.
    /// - returns: Ein Array von Tokens. Jeder String wurde in lowercase umgewandelt.
    private func createTokens(s: String) -> [String] {
        let words = s.characters
            .split{$0 == " "}
            .map(String.init)
        return Array(Set(words.map{$0.lowercaseString}))
    }
    
    /// - parameter resultString: Z.B. der String, anhand dessen eine der Suchfunktionen einen Treffer erzielt hat.
    /// - parameter searchString: Z.B. der String, nach dem eine Suchfunktion in der Datenbank gesucht hat. 
    /// - returns: Wert der angibt, zu wieviel Prozent der resultString auf den searchString matcht.
    private func getMatch(resultString: String, searchString: String) -> Double {
        let mismatch = resultString.lowercaseString.stringByReplacingOccurrencesOfString(searchString, withString: "")
        let match = 1-Double(mismatch.characters.count) / Double(resultString.characters.count)
        return match
    }
    
    
    /// - parameter monuments:  Array aus Tupel. Jedes Tupel enthält den Match-Wert (getMatch(...))
    ///                         und das zugehörige Monument
    /// - returns:              Array aus Tupel aus Ranking-Wert und Denkmal. Sämtliche Suchergebnisse, 
    ///                         die auf ein und das selbe Denkmal verweisen werden vereinigt, 
    ///                         wobei der Match-Wert addiert wird, und somit zu einem höheren Ranking führt. 
    ///                         Das Ergebnis wird anhand der Rankingwerte sortiert.
    private func rankMonuments(monuments:[(Double,DMBMonument)]) -> [(Double, DMBMonument)]{
        return monuments.groupBy({$0.1.getObjNr()!}).map({groupedMon -> (Double,DMBMonument) in
            let m:DMBMonument = groupedMon.1[0].1
            return groupedMon.1.reduce((0,m), combine: {
                (m1,m2) -> (Double, DMBMonument) in
                return (m1.0 + m2.0, m)
                })
            }).sort({$0.0 > $1.0})
    }
/*
      ___
     / _ \ _   _  ___ _ __ _   _
    | | | | | | |/ _ \ '__| | | |
    | |_| | |_| |  __/ |  | |_| |
     \__\_\\__,_|\___|_|   \__, |
                           |___/
     __  __             _             _       _   _
    |  \/  | __ _ _ __ (_)_ __  _   _| | __ _| |_(_) ___  _ __
    | |\/| |/ _` | '_ \| | '_ \| | | | |/ _` | __| |/ _ \| '_ \
    | |  | | (_| | | | | | |_) | |_| | | (_| | |_| | (_) | | | |
    |_|  |_|\__,_|_| |_|_| .__/ \__,_|_|\__,_|\__|_|\___/|_| |_|
                         |_|
    */
    
    
    
//    private func rankedMonumentsByNameWithFilter(tokens:[String]) -> [(Double,DMBMonument)] {
//        func searchMonumentsByName(token: String) -> [(Double,DMBMonument)] {
//            let monuments = Table(DMBTable.monument)
//            return dbConnection.prepare(DMBModel.appendFilter(DMBModel.getQu(), filter: filter)
//                .filter(monuments[DMBMonument.Expressions.name].lowercaseString.like(searchableString(token))))
//                .map({row -> (Double,DMBMonument) in
//                    let monum = DMBConverter.rowToMonument(row, connection: dbConnection,table: monuments)
//                    let match = getMatch(monum.getName()!, searchString: token)     // Da das query ein Ergebnis ergeben hat,
//                    // darf hier ein promise gemacht werden
//                    return (match,monum)
//                })
//        }
//        return rankMonuments(tokens.flatMap({word -> [(Double,DMBMonument)] in
//            return searchMonumentsByName(word)
//        }))
//
//    }
    
    private static func appendFilter(var statement: Table, filter:DMBFilter) -> Table {
        let SQLDateFormatter: NSDateFormatter = {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        let monuments = Table(DMBTable.monument)
        let district = Table(DMBTable.district)
        let districtRel = Table(DMBTable.districtRel)
        let date = Table(DMBTable.dating)
        let type = Table(DMBTable.type)
        statement = statement
            .join(type, on: type[DMBType.Expressions.id] == monuments[DMBMonument.Expressions.typeId])
            .join(date, on: date[DMBTimePeriod.Expressions.id] == monuments[DMBMonument.Expressions.datingId])
            .join(districtRel, on: districtRel[DMBDistrictRelation.Expressions.monumentId] == monuments[DMBMonument.Expressions.id])
            .join(district, on: district[DMBDistrict.Expressions.id] == districtRel[DMBDistrictRelation.Expressions.districtId])
        
        // Filter types
        if !filter.ensemble {statement = statement.filter(type[DMBDistrict.Expressions.name]                        != "Ensemble")}
        if !filter.ensembleteil {statement = statement.filter(type[DMBDistrict.Expressions.name]                    != "Ensembleteil")}
        if !filter.gesamtanlage {statement = statement.filter(type[DMBDistrict.Expressions.name]                    != "Gesamtanlage")}
        if !filter.baudenkmal {statement = statement.filter(type[DMBDistrict.Expressions.name]                      != "Baudenkmal")}
        if !filter.gartendenkmal {statement = statement.filter(type[DMBDistrict.Expressions.name]                   != "Gartendenkmal")}
        if !filter.bodendenkmal {statement = statement.filter(type[DMBDistrict.Expressions.name]                    != "Bodendenkmal")}
        
        // Filter District
        if !filter.charlottenburgWilmersdorf {statement = statement.filter(district[DMBDistrict.Expressions.name]   != "Charlottenburg-Wilmersdorf")}
        if !filter.steglitzZehlendorf {statement = statement.filter(district[DMBDistrict.Expressions.name]          != "Steglitz-Zehlendorf")}
        if !filter.spandau {statement = statement.filter(district[DMBDistrict.Expressions.name]                     != "Spandau")}
        if !filter.friedrichshainKreuzberg {statement = statement.filter(district[DMBDistrict.Expressions.name]     != "Friedrichshain-Kreuzberg")}
        if !filter.tempelhofSchöneberg {statement = statement.filter(district[DMBDistrict.Expressions.name]         != "Tempelhof-Schöneberg")}
        if !filter.mitte {statement = statement.filter(district[DMBDistrict.Expressions.name]                       != "Mitte")}
        if !filter.neukölln {statement = statement.filter(district[DMBDistrict.Expressions.name]                    != "Neukölln")}
        if !filter.lichtenberg {statement = statement.filter(district[DMBDistrict.Expressions.name]                 != "Lichtenberg")}
        if !filter.marzahnHellersdorf {statement = statement.filter(district[DMBDistrict.Expressions.name]          != "Marzahn-Hellersdorf")}
        if !filter.pankow {statement = statement.filter(district[DMBDistrict.Expressions.name]                      != "Pankow")}
        if !filter.reinickendorf {statement = statement.filter(district[DMBDistrict.Expressions.name]               != "Reinickendorf")}
        if !filter.treptowKöpenick {statement = statement.filter(district[DMBDistrict.Expressions.name]             != "Treptow-Köpenick")}
        
        // Filter timePeriod
        if filter.dateEnabled {
            let from = SQLDateFormatter.stringFromDate(filter.from)
            let to   = SQLDateFormatter.stringFromDate(filter.to)
            statement = statement.filter(date[DMBTimePeriod.Expressions.from] >= from)
            statement = statement.filter(date[DMBTimePeriod.Expressions.to] <= to)
        }
        return statement
    }
    
    private func getBasicQuery(filtered:Bool) -> Table {
        let monuments   = Table(DMBTable.monument)
        if filtered {return DMBModel.appendFilter(monuments, filter: filter)}
        else {return monuments}
    }
}



