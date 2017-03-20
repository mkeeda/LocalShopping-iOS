//
//  User.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 3/1/17.
//  Copyright © 2017 IppeiMUKAIDA. All rights reserved.
//

import ObjectMapper

class User: Mappable {
    var id: Int?
    var username: String?
    var password: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var userProfile: UserProfile

    init(
        id: Int? = nil,
        username: String? = nil,
        password: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        email: String? = nil,
        userProfile: UserProfile
        ) {

        self.id = id
        self.username = username
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.userProfile = userProfile
    }

    required convenience init?(map: Map) {
        self.init(userProfile: UserProfile())
    }

    func mapping(map: Map) {
        id <- map["id"]
        username <- map["username"]
        password <- map["password"]
        firstName <- map["first_name"]
        lastName <- map["last_name"]
        email <- map["email"]
        userProfile.id <- map["UserProfile"]
    }

    // ユーザ名は30文字までなので，UUIDを切り詰める関数
    class func uuidLength30() -> String? {
        guard let uuid = UIDevice.current.identifierForVendor?.uuidString else {
            return nil
        }
        let start = uuid.startIndex
        let end = uuid.index(start, offsetBy: 30)
        let uuidLength30 = uuid.substring(with: start..<end)

        return uuidLength30
    }

    //パスワードは自身のユーザネームを2つ連結したもの
    class func generatePassword() -> String? {
        guard let username = User.uuidLength30() else {
            return nil
        }
        let password = username + username
        return password
    }
}
