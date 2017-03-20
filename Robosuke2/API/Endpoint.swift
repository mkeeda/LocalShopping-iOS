//
//  Endpoint.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 9/21/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import Alamofire
import ObjectMapper

//GETやPUTはenumで対応する

class Endpoint {
    enum Login: RequestProtocol {
        typealias ResponseType = LoginEntity

        case authorization
        case refresh(token: String)

        var method: HTTPMethod {
            return .post
        }

        var path: String {
            switch self {
            case .authorization:
                return "/api/token-auth/"
            case .refresh:
                return "/api/token-refresh/"
            }
        }

        var headers: [String : String]? {
            return nil
        }

        var parameters: [String : Any]? {
            switch self {
            case .authorization:
                guard 
                    let username = User.uuidLength30(),
                    let password = User.generatePassword()
                else {
                    return nil
                }
                print("username: \(username)")
                print("password: \(password)")
                return [
                    "username": username,
                    "password": password,
                ]
            case .refresh(let token):
                return ["token": token]
            }
        }
    }

    enum RequestProduct: RequestProtocol {
        typealias ResponseType = Product

        case get(category: Category<[Product]>)

        var method: HTTPMethod {
            switch self {
            case .get:
                return .get
            }
        }

        var path: String {
            switch self {
            case let .get(category):
                return "/api/products/?min_cat=\(category.min)&max_cat=\(category.max)"
            }
        }
    }

    enum RequestShelf: RequestProtocol {
        typealias ResponseType = Shelf

        case get(sellerId: Int, category: Category<[Shelf]>)

        var method: HTTPMethod {
            switch self {
            case .get:
                return .get
            }
        }

        var path: String {
            switch self {
            case let .get(sellerId, category):
                return "/api/shelf/?seller_id=\(sellerId)&min_cat=\(category.min)&max_cat=\(category.max)"
            }
        }
    }

    enum RequestImage: RequestProtocol {
        typealias ResponseType = Data

        case get(imgName: String)

        var method: HTTPMethod {
            switch self {
            case .get:
                return .get
            }
        }

        var path: String {
            switch self {
            case let .get(imgName):
                return "/media/\(imgName)"
            }

        }
    }

    enum RequestOrder: RequestProtocol {
        typealias ResponseType = Order

        case get
        case post(json: Dictionary<String, Any>)

        var method: HTTPMethod {
            switch self {
            case .get:
                return .get
            case .post:
                return .post
            }
        }

        var path: String {
            return "/api/order/"
        }

        var parameters: [String: Any]? {
            switch self {
            case .get:
                return nil
            case let .post(json):
                return json
            }
        }
    }

    enum RequestUser: RequestProtocol {
        typealias ResponseType = User

        case get
        case post(firstName: String, LastName: String, email: String)

        var method: HTTPMethod {
            switch self {
            case .get:
                return .get
            case .post:
                return .post
            }
        }

        var path: String {
            return "/api/user/"
        }

        var parameters: [String : Any]? {
            switch self {
            case .get:
                return nil
            case let .post(firstName, lastName, email):
                guard
                    let username = User.uuidLength30(),
                    let password = User.generatePassword()
                    else {
                    print("Failed to create username or password")
                    return nil
                }
                return [
                    "password": password,
                    "username": username,
                    "first_name": firstName,
                    "last_name": lastName,
                    "email": email,
                ]
            }
        }
    }

    enum RequestUserProfile: RequestProtocol {
        typealias ResponseType = UserProfile

        case get
        case put(userProfile: UserProfile)

        var method: HTTPMethod {
            switch self {
            case .get:
                return .get
            case .put:
                return .put
            }
        }

        var path: String {
            switch self {
            case .get:
                return "/api/userProfile/"
            case let .put(userProfile):
                guard let id = userProfile.id
                    else {
                        fatalError("Request userProfile: userProfile ID is nil")
                }
                return "/api/userProfile/\(id)/"
            }
        }

        var parameters: [String : Any]? {
            switch self {
            case .get:
                return nil
            case let .put(userProfile):
                guard
                    let zipcode = userProfile.zipcode,
                    let address = userProfile.address,
                    let phoneNumber = userProfile.phoneNumber,
                    let areaId = userProfile.area.id,
                    let busLine = userProfile.busLine.name,
                    let busStop = userProfile.busStop.name
                    else { return nil }
                return [
                    "zip_code": zipcode,
                    "Address": address,
                    "PhoneNumber": phoneNumber,
                    "area": areaId,
                    "busLine": busLine,
                    "busStop": busStop
                ]
            }
        }
    }

    enum RequestArea: RequestProtocol {
        typealias ResponseType = BusInfo

        case get

        var method: HTTPMethod {
            return .get
        }

        var path: String {
            return "/api/area/"
        }
    }
    
    enum RequestBusLine: RequestProtocol {
        typealias ResponseType = BusInfo

        case get(areaId: Int)

        var method: HTTPMethod {
            return .get
        }

        var path: String {
            switch self {
            case let .get(areaId):
                return "/api/bus/bus-lines/?area=\(areaId)"
            }
        }
    }

    enum RequestBusStop: RequestProtocol {
        typealias ResponseType = BusInfo

        case get(lineName: String)

        var method: HTTPMethod {
            return .get
        }

        var path: String {
            switch self {
            case let .get(lineName):
                return "/api/bus/bus-stops/?line_name=\(lineName)"
            }
        }
    }
}

