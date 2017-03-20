//
//  shelf.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 6/9/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import ObjectMapper

class Shelf: Mappable {
	var id: Int?                    //shelfの固有ID
	var sellerId: Int?	           	//商店ID
	var productId: Int?	           	//商品ID
	var price: Price?	           	//店独自の商品価格
	var detail: String?	           	//商品に対する商店の説明
	var createdAt: String?          //shelfが作られた日時
    var productDetail: Product?   //商品の詳細
	
	init(
		id: Int? = nil,
		sellerId: Int? = nil,
		productId: Int? = nil,
		price: Price? = nil,
		detail: String? = nil,
		createdAt: String? = nil,
        productDetail: Product? = nil
		){
		
		self.id = id
		self.sellerId = sellerId
		self.productId = productId
		self.price = price
		self.detail = detail
		self.createdAt = createdAt
        self.productDetail = productDetail
	}

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id <- map["id"]
        sellerId <- map["seller_id"]
        productId <- map["product_id"]
        price <- (map["price"], TransformOf<Price, Int>(
            fromJSON: { Price(nonTaxPrice: $0!) },
            toJSON: { $0?.nonTaxPrice }))
        detail <- map["detail"]
        createdAt <- map["createdAt"]
        productDetail <- map["product_detail"]
    }
}
