//
//  Order.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 6/14/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import ObjectMapper

class Order: Mappable {
	var id: Int?                        //注文ID
	var sellerId: Int?                  //商店ID
	var createdAt: Date?              //注文日
	var price: Price?                   //支払金額
	var buyerId: Int?                   //顧客ID
	var orderDetails: [OrderDetail]?		//注文内容
	var trans: String?                  //バスの情報
	var bus: Int?
	var state: Int?                     //配達状況
	
    enum DeliveryState: String {
		case Check = "注文確認中"
		case Ready = "出荷準備中"
		case Shipped = "出荷完了"
		case Delivered = "配達完了"
    }

	init(
		id: Int? = nil,
		sellerId: Int? = nil,
		createdAt: Date? = nil,
		price: Price? = nil,
		buyerId: Int? = nil,
		orderDetails: [OrderDetail]? = nil,
		trans: String? = nil,
		bus: Int? = nil,
		state: Int? = nil
	){
		self.id = id
		self.sellerId = sellerId
		self.createdAt = createdAt
		self.price = price
		self.buyerId = buyerId
		self.orderDetails = orderDetails
		self.trans = trans
		self.bus = bus
		self.state	= state
	}

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id <- map["id"]
        sellerId <- map["seller_id"]
        createdAt <- (map["createdAt"], DateTransform())
        price <- (map["price"], TransformOf<Price, Int>(
            fromJSON: { Price(nonTaxPrice: $0!) },
            toJSON: { $0?.nonTaxPrice}))
        buyerId <- map["buyer_id"]
        orderDetails <- map["orderdetails"]
        trans <- map["trans"]
        bus <- map["bus"]
        state <- map["state"]
    }
	
	//配達状況を返す
	func getState() -> DeliveryState {
        if let state = state {
            switch state {
            case 0:
                return .Check
            case 1:
                return .Ready
            case 2:
                return .Shipped
            case 3:
                return .Delivered
            default:
                return .Check
            }
        }
        return .Check
	}
	
	//createAtの日付を整形
	func setupFormatOfCreateAt(_ afterFormat: String ) -> String {
		let dateFormatter = DateFormatter()
		
		if let date = createdAt {
			dateFormatter.dateFormat = afterFormat
			let fixedDateString = dateFormatter.string(from: date)
			
			return fixedDateString
		}
        return String(describing: createdAt)
	}
}


class DateTransform: TransformType {
	typealias Object = Date
	typealias JSON = String

	init() {}

	func transformFromJSON(_ value: Any?) -> Date? {
		if let dateString = value as? String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'+09:00'" // Choose format
            let date = formatter.date(from: dateString)
			return date
		}
		return nil
	}

	func transformToJSON(_ value: Date?) -> String? {
		if let date = value {
			return String(describing: date)
		}
		return nil
	}
}

class OrderDetail: Mappable {
    var productId: Int?
    var price: Price?
    var numOfOrders: Int?

    required init?(map: Map) {}

    func mapping(map: Map) {
        productId <- map["product_id"]
        price <- (map["price"], TransformOf<Price, Int>(
            fromJSON: { Price(nonTaxPrice: $0!) },
            toJSON: { $0?.nonTaxPrice }))
        numOfOrders <- map["number"]
    }
}
