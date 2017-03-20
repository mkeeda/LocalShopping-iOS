//
//  OrderCheckCell.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 10/1/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import UIKit

class OrderCheckCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var productImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
