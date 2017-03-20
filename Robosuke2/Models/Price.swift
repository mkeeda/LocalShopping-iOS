//
//  Price.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 6/25/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import Foundation

class Price {
	var nonTaxPrice: Int
    var taxPrice: Int
    fileprivate var tax: Double = 8
    fileprivate let numFormatter = NumberFormatter()
	
    init(nonTaxPrice: Int){
        self.nonTaxPrice = nonTaxPrice
		let taxPrice = Double(nonTaxPrice) * (1 + tax / 100.0)
        self.taxPrice = Int(taxPrice)

		numFormatter.numberStyle = NumberFormatter.Style.decimal
		numFormatter.groupingSeparator = ","
		numFormatter.groupingSize = 3
	}
	
	//3桁ごとにカンマを打った価格Stringを返す
    //税抜き
	func getNonTaxPriceStringWithFormated() -> String {
        return numFormatter.string(from: NSNumber(value: nonTaxPrice))!
	}

    //税込み
	func getTaxPriceStringWithFormated() -> String {
        return numFormatter.string(from: NSNumber(value: taxPrice))!
	}
}
