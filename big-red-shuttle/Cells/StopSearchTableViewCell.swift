//
//  StopSearchTableViewCell.swift
//  big-red-shuttle
//
//  Created by Kevin Greer on 11/2/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import UIKit

class StopSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nextArrivalLabel: UILabel!
    
    func setupCell(stop: Stop) {
        preservesSuperviewLayoutMargins = false
        separatorInset = .zero
        layoutMargins = .zero
        
        nameLabel.text = stop.name
        nameLabel.textColor = .brsblack
        
        nextArrivalLabel.text = getMessage(messageType: .Search, stop: stop)
        nextArrivalLabel.textColor = .brsgrey
    }
}
