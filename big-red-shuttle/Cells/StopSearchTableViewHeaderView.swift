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
    
    let kPadding: CGFloat = 16
    let kCarrotHeight: CGFloat = 10
    let kCarrotWidth: CGFloat = 20
    let kBottomBorderThickness: CGFloat = 0.5

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        let carrotContainerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: kCarrotWidth, height: kCarrotHeight)))
        carrotContainerView.center = CGPoint(x: bounds.maxX-kPadding-kCarrotWidth/2, y: bounds.midY)
        downCarrotImageView = UIImageView(frame: carrotContainerView.bounds)
        addSubview(carrotContainerView)
        carrotContainerView.addSubview(downCarrotImageView)
        downCarrotImageView.image = #imageLiteral(resourceName: "arrow")
        
        findStopsLabel = UILabel()
        findStopsLabel.text = "Find Big Red Shuttle"
        findStopsLabel.sizeToFit()
        findStopsLabel.center = CGPoint(x: kPadding+findStopsLabel.frame.width/2, y: bounds.midY)
        findStopsLabel.textColor = .brsblack
        findStopsLabel.font = .systemFont(ofSize: 14)
        addSubview(findStopsLabel)
        
        let bottomBorderView = UIView(frame: CGRect(x: 0, y: frame.height-kBottomBorderThickness, width: frame.width, height: kBottomBorderThickness))
        bottomBorderView.backgroundColor = .bordergray
        addSubview(bottomBorderView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animate(open: Bool, duration: TimeInterval) {
        let color = open ? UIColor.brsgrey : UIColor.brsblack
        let transform = CATransform3DRotate(downCarrotImageView.layer.transform, CGFloat(M_PI), 1.0, 0, 0)
        UIView.transition(with: findStopsLabel, duration: duration, options: .transitionCrossDissolve, animations: {
            self.findStopsLabel.textColor = color
            self.downCarrotImageView.layer.transform = transform
            }, completion: nil)
    }
}
