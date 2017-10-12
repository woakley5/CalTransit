//
//  TransferTableViewCell.swift
//  CalTransit
//
//  Created by Will Oakley on 10/11/17.
//  Copyright © 2017 Will Oakley. All rights reserved.
//

import UIKit

class TransferTableViewCell: UITableViewCell {

    @IBOutlet weak var transferInfoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
