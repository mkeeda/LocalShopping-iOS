//
//  LoginEntity.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 10/20/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import ObjectMapper

class LoginEntity: Mappable {
    var token: String = ""

    required init?(map: Map) {}

    func mapping(map: Map) {
        self.token <- map["token"]
    }
}
