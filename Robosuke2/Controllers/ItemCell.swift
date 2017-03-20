//
//  CustomCell.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 4/24/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import UIKit

class ItemCell: UICollectionViewCell {
	
	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var image: UIImageView!
	@IBOutlet weak var number: UILabel!
	@IBOutlet weak var price: UILabel!
	@IBOutlet weak var stepper: UIStepper!
	@IBOutlet weak var stepperHeightConstraint: NSLayoutConstraint!
	
	override init(frame: CGRect){
		super.init(frame: frame)
	}
	required init?(coder aDecoder: NSCoder){
		super.init(coder: aDecoder)
	}
	
}
