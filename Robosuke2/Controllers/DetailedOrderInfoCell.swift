//
//  DetailedOrderInfoCell.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 6/14/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import UIKit

class DetailedOrderInfoCell: UICollectionViewCell {
	@IBOutlet weak var date: UILabel!
	@IBOutlet weak var sellerName: UILabel!
	@IBOutlet weak var price: UILabel!
	@IBOutlet weak var state: UILabel!
	
	override init(frame: CGRect){
		super.init(frame: frame)
	}
	required init?(coder aDecoder: NSCoder){
		super.init(coder: aDecoder)
	}
}
