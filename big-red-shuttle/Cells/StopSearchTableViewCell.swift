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
 
        let nextArrivalToday = stop.nextArrivalToday()
        nextArrivalLabel.text = (nextArrivalToday != "--") ? "Next shuttle at \(nextArrivalToday) today" : "Next shuttle at \(stop.nextArrival())"
        nextArrivalLabel.textColor = .brsgrey
    }
}
