//
//  StopSearchTableViewCell.swift
//  big-red-shuttle
//
//  Created by Kevin Greer on 11/2/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import UIKit

class StopSearchTableViewCell: UITableViewCell {
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nextArrivesLabel: UILabel!
    @IBOutlet weak var walkingDistanceLabel: UILabel!
    func setupCell() {
        preservesSuperviewLayoutMargins = false
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        indicatorView.layer.cornerRadius = indicatorView.frame.height/2
    }
}
