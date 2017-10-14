//
//  TripSegmentTableViewCell.swift
//  CalTransit
//
//  Created by Will Oakley on 10/11/17.
//  Copyright © 2017 Will Oakley. All rights reserved.
//

import UIKit

class TripSegmentTableViewCell: UITableViewCell {

    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var departTimeLabel: UILabel!
    @IBOutlet weak var arriveTimeLabel: UILabel!
    @IBOutlet weak var background: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
