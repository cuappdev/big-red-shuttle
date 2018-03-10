//
//  StopSearchTableViewHeaderView.swift
//  big-red-shuttle
//
//  Created by Kevin Greer on 11/1/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import UIKit

class StopSearchTableViewHeaderView: UIView {
    
    var downCarrotImageView: UIImageView!
    var findStopsLabel: UILabel!
    
    let kPadding: CGFloat = 15
    let kCarrotWidth: CGFloat = 16
    let kCarrotHeight: CGFloat = 9
    let kBottomBorderThickness: CGFloat = 0.5

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white

        downCarrotImageView = UIImageView(image: #imageLiteral(resourceName: "ArrowIcon"))
        downCarrotImageView.frame = CGRect(origin: .zero, size: CGSize(width: kCarrotWidth, height: kCarrotHeight))
        downCarrotImageView.center = CGPoint(x: bounds.maxX - kPadding - kCarrotWidth/2, y: bounds.midY)
        addSubview(downCarrotImageView)
        
        findStopsLabel = UILabel()
        findStopsLabel.text = "Find Big Red Shuttle stops"
        findStopsLabel.font = UIFont(name: "SFUIDisplay-Regular", size: 14.0)!
        findStopsLabel.textColor = .brsblack
        findStopsLabel.sizeToFit()
        findStopsLabel.center = CGPoint(x: kPadding + findStopsLabel.frame.width/2, y: bounds.midY)
        addSubview(findStopsLabel)
        
        let bottomBorderView = UIView(frame: CGRect(x: 0, y: frame.height - kBottomBorderThickness, width: frame.width, height: kBottomBorderThickness))
        bottomBorderView.backgroundColor = .searchbottombordergray
        addSubview(bottomBorderView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animate(open: Bool, duration: TimeInterval) {
        backgroundColor = open ? .brslightgrey : .white
        
        let transform = CATransform3DRotate(downCarrotImageView.layer.transform, CGFloat(Double.pi), 1.0, 0, 0)
        UIView.transition(with: findStopsLabel, duration: duration, options: .transitionCrossDissolve, animations: {
            self.findStopsLabel.textColor = open ? .brsgrey : .brsblack
            self.downCarrotImageView.layer.transform = transform
        })
    }
    
}
