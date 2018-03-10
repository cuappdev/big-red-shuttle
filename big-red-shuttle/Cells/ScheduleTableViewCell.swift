//
//  ScheduleTableViewCell.swift
//  
//
//  Created by Monica Ong on 11/2/16.
//
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {
    
    let redLinePercOffset: CGFloat = 0.23
    
    var stopLabel: UILabel = UILabel()
    var timeLabel: UILabel = UILabel()
    var routeDot: CAShapeLayer = CAShapeLayer()
    var routeLine: UIView = UIView()
    var separator: UIView = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        isUserInteractionEnabled = false

        timeLabel.font = UIFont(name: "SFUIDisplay-Regular", size: 12.0)
        timeLabel.textColor = .scheduletimegrey
        
        routeLine.backgroundColor = .brsred
        routeDot.strokeColor = UIColor.brsred.cgColor
        routeDot.lineWidth = 3.0
        
        stopLabel.font = UIFont(name: "SFUIDisplay-Regular", size: 14.0)
        stopLabel.textColor = .brsblack
        
        separator.backgroundColor = .brsgray
        
        contentView.addSubview(timeLabel)
        contentView.addSubview(routeLine)
        contentView.addSubview(stopLabel)
        contentView.addSubview(separator)
        contentView.layer.addSublayer(routeDot)
    }
    
    override func layoutSubviews() {
        let scheduleViewBounds = UIScreen.main.bounds
        let height = contentView.frame.height
        
        timeLabel.center = CGPoint(x: scheduleViewBounds.width * redLinePercOffset/2, y: contentView.frame.midY)
        
        routeLine.frame = CGRect(x: scheduleViewBounds.width * redLinePercOffset, y: 0, width: 3.0, height: height)
        
        stopLabel.frame = CGRect(x: routeLine.frame.maxX + 20, y: 0, width: scheduleViewBounds.width * (1 - redLinePercOffset), height: height)
        stopLabel.center.y = contentView.frame.midY
        
        separator.frame = CGRect(x: stopLabel.frame.minX, y: height - 1, width: scheduleViewBounds.width, height: 1)
        
        let circlePath = UIBezierPath(arcCenter: routeLine.center, radius: CGFloat(4.4), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        routeDot.path = circlePath.cgPath
        routeDot.fillColor = UIColor.white.cgColor
    }
    
    func configStop(loop: Bool){
        timeLabel.font = loop ? UIFont(name: "SFUIDisplay-Bold", size: 12.0) : UIFont(name: "SFUIDisplay-Regular", size: 12.0)
        timeLabel.sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
