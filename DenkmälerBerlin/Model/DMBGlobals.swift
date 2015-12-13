//
//  DMBGlobals.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 21.11.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import Foundation

struct DMBTable {
    static let monument             = "monument"
    static let dating               = "dating"
    static let monumentNotion       = "monument_notion"
    static let route                = "route"
    static let district             = "district"
    static let subDistrict          = "sub_district"
    static let type                 = "type"
    static let picture              = "picture"
    static let address              = "address"
    static let addressRel           = "address_rel"
    static let participant          = "participant"
    static let participantRel       = "participant_rel"
    static let participantType      = "participant_type"
    static let monumentNotionRel    = "monument_notion_rel"
    static let districtRel          = "district_rel"
    static let subDistrictRel       = "sub_district_rel"
}

struct DMBAttribut {
    static let id                   = "id"
    static let name                 = "name"
    static let objNr                = "obj_nr"
    static let descr                = "descr"
    static let typeId               = "type_id"
    static let superMonumentId      = "super_monument_id"
    static let length               = "length"
    static let url                  = "url"
    static let beginning            = "beginning"
    static let ending               = "ending"
    static let lat                  = "lat"
    static let long                 = "long"
    static let street               = "street"
    static let nr                   = "nr"
    static let linkId               = "link_id"
    static let monumentNotionId     = "monument_notion_id"
    static let participantId        = "participant_id"
    static let participantTypeId    = "participant_type_id"
    static let monumentId           = "monument_id"
    static let addressId            = "address_id"
    static let districtId           = "district_id"
    static let subDistrictId        = "sub_district_id"
    static let datingId             = "dating_id"
}

struct DMBSearchKey {
    static let byName           = "byName"
    static let byLocation       = "byLocation"
    static let byNotion         = "byNotion"
    static let byParticipant    = "byParticipant"
}