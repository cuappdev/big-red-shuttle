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
    @IBOutlet weak var nextArrivesLabel: UILabel!
    func setupCell(stop: Stop) {
        preservesSuperviewLayoutMargins = false
        separatorInset = .zero
        layoutMargins = .zero
        
        nameLabel.text = stop.name
        nameLabel.textColor = .brsblack
        nextArrivesLabel.textColor = .brsgreyedout
        nextArrivesLabel.text = "Next bus comes at \(stop.nextArrival())"
    }
}
