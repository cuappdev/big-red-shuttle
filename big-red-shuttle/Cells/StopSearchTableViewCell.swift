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
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        nameLabel.text = stop.name
        nameLabel.textColor = .brsblack
        nextArrivesLabel.textColor = .brsgreyedout
        nextArrivesLabel.text = "Next bus comes at \(stop.nextArrival())"
    }
}
