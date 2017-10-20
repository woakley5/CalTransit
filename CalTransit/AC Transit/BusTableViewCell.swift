//
//  BusTableViewCell.swift
//  CalTransit
//
//  Created by Will Oakley on 10/19/17.
//  Copyright © 2017 Will Oakley. All rights reserved.
//

import UIKit

class BusTableViewCell: UITableViewCell {

    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var arriveTimeLabel: UILabel!
    @IBOutlet weak var delayLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    
    var vehicleId: String!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
