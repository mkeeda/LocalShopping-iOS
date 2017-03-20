//
//  Product.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 5/2/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import UIKit
import ObjectMapper

//商品データのクラス

class Product: Mappable{
	var id: Int?			//product_id
	var name: String?		//商品名
	var imgName: String?		//商品の画像ファイル名
	var barcode: String?		//バーコード
	var cat: Int?			//カテゴリ番号
	var price: Price?		//価格
	var com: String?		//商品説明
	var updatedAt: Date?  //データの最終更新時間
	var numOfOrders: Int?  	//注文数

    init(
        name: String? = "",
        price: Price? = Price(nonTaxPrice: 0),
        imgName: String? = "",
        numOfOrders: Int? = 0,
        barcode: String? = "",
        cat: Int? = 0,
        com: String? = "",
        updatedAt: Date? = nil,
        id: Int? = 0
        ){

        self.name = name
        self.price = price
        self.imgName = imgName
        self.numOfOrders = numOfOrders
        self.barcode = barcode
        self.cat = cat
        self.com = com
        self.updatedAt = updatedAt
        self.id = id
    }

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        imgName <- map["image"]
        barcode <- map["barcode"]
        cat <- map["cat_id"]
        price <- (map["price"], TransformOf<Price, Int>(
            fromJSON: { Price(nonTaxPrice: $0!) },
            toJSON: { $0?.nonTaxPrice }))
        com <- map["com"]
        updatedAt <- (map["updatedAt"], DateTransform())
    }

	func loadImage() -> UIImage?{
		let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        if let imgName = imgName {
            let fullpath = path + "/" + imgName
            let image = UIImage(contentsOfFile: fullpath)
            if image == nil {
                print("missing image at:" + fullpath)
            }
            return image
        }
        return nil
	}
}

enum Category<T> {
    case processedFoods(value: T?)
    case freshFoods(value: T?)
    case snacks(value: T?)
    case drink(value: T?)
    case otherFoods(value: T?)
    case dailyNecessities(value: T?)
    case others(value: T?)

    var min: Int {
        switch self {
        case .processedFoods:
            return 1100
        case .freshFoods:
            return 1200
        case .snacks:
            return 1300
        case .drink:
            return 1400
        case .otherFoods:
            return 1500
        case .dailyNecessities:
            return 2000
        case .others:
            return 3000
        }
    }

    var max: Int {
        switch self {
        case .processedFoods:
            return 1199
        case .freshFoods:
            return 1299
        case .snacks:
            return 1399
        case .drink:
            return 1499
        case .otherFoods:
            return 1599
        case .dailyNecessities:
            return 2999
        case .others:
            return 9999
        }
    }

    var name: String {
        switch self {
        case .processedFoods:
            return "加工食品"
        case .freshFoods:
            return "生鮮食品"
        case .snacks:
            return "菓子"
        case .drink:
            return "飲料・酒"
        case .otherFoods:
            return "その他食品"
        case .dailyNecessities:
            return "日用品"
        case .others:
            return "その他"
        }
    }

    mutating func setValue(_ value: T) {
        switch self {
        case .processedFoods:
            self = .processedFoods(value: value)
        case .freshFoods:
            self = .freshFoods(value: value)
        case .snacks:
            self = .snacks(value: value)
        case .drink:
            self = .drink(value: value)
        case .otherFoods:
            self = .otherFoods(value: value)
        case .dailyNecessities:
            self = .dailyNecessities(value: value)
        case .others:
            self = .others(value: value)
        }
    }

    func getValue() -> T? {
        switch self {
        case .processedFoods(let value):
            return value
        case .freshFoods(let value):
            return value
        case .snacks(let value):
            return value
        case .drink(let value):
            return value
        case .otherFoods(let value):
            return value
        case .dailyNecessities(let value):
            return value
        case .others(let value):
            return value
        }
    }
}
