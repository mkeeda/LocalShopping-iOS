//
//  OrderCell.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 5/2/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import UIKit

class OrderCell: UITableViewCell {

	@IBOutlet weak var orderTime: UILabel!
	@IBOutlet weak var price: UILabel!
	@IBOutlet weak var state: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
