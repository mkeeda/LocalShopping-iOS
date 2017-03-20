//
//  UserProfile.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 3/16/17.
//  Copyright © 2017 IppeiMUKAIDA. All rights reserved.
//

import ObjectMapper

class UserProfile: Mappable {
    var id: Int?
    var zipcode: String?
    var address: String?
    var phoneNumber: String?
    var area: BusInfo
    var busLine: BusInfo
    var busStop: BusInfo
    var userId: Int?

    init(
        id: Int? = nil,
        zipcode: String? = nil,
        address: String? = nil,
        phoneNumber: String? = nil,
        area: BusInfo = BusInfo(),
        busLine: BusInfo = BusInfo(),
        busStop: BusInfo = BusInfo(),
        userId: Int? = nil
        ) {
        self.id = id
        self.zipcode = zipcode
        self.address = address
        self.phoneNumber = phoneNumber
        self.area = area
        self.busLine = busLine
        self.busStop = busStop
        self.userId = userId
    }

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id <- map["id"]
        zipcode <- map["zip_code"]
        address <- map["Address"]
        phoneNumber <- map["PhoneNumber"]
        area.id <- map["area"]
        busLine <- map["busLine"]
        busStop <- map["busStop"]
        userId <- map["user"]
    }
}

