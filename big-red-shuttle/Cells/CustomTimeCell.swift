//
//  CustomTimeCell.swift
//  big-red-shuttle
//
//  Created by Austin Astorga on 11/7/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import UIKit

class CustomTimeCell: UICollectionViewCell {
    
    var textLabel: UILabel
    
    override init(frame: CGRect) {
        textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 58, height: 20.5))
        super.init(frame: frame)
        textLabel.font = .systemFont(ofSize: 13.5, weight: UIFont.Weight.regular)
        textLabel.textAlignment = .center
        textLabel.textColor = .lightGray
        contentView.addSubview(textLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
}
