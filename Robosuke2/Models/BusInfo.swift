//
//  BusInfo.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 3/13/17.
//  Copyright © 2017 IppeiMUKAIDA. All rights reserved.
//

import ObjectMapper

class BusInfo: Mappable {
    var id: Int?
    var name: String?

    init(id: Int? = nil, name: String? = nil) {
        self.id = id
        self.name = name
    }

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
}
