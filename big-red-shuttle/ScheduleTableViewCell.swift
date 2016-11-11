//
//  ScheduleTableViewCell.swift
//  
//
//  Created by Monica Ong on 11/2/16.
//
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {
    
    var stop: UILabel = UILabel()
    var time: UILabel = UILabel()
    var dot: CAShapeLayer = CAShapeLayer()
    var line: UIView = UIView()
    var separator: UIView = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        isUserInteractionEnabled = false

        line.backgroundColor = .brsred

        time.font = UIFont(name: "HelveticaNeue-Light", size: 11.5)
        time.textColor = .brsblack
        
        stop.font = UIFont(name: "HelveticaNeue", size: 13.0)
        stop.textColor = .brsblack
        
        separator.backgroundColor = .brslightgrey
        
        dot.strokeColor = UIColor.brsred.cgColor
        dot.lineWidth = 3.0
        
        contentView.addSubview(stop)
        contentView.addSubview(line)
        contentView.addSubview(time)
        contentView.addSubview(separator)
        contentView.layer.addSublayer(dot)
    }
    
    override func layoutSubviews() {
        let scheduleViewBounds = UIScreen.main.bounds
        let height = contentView.frame.height
        
        line.frame = CGRect(x: scheduleViewBounds.width * 0.20, y: 0, width: 3.5, height: height)

        time.center.y = contentView.center.y
        time.center.x = scheduleViewBounds.width * 0.10
        
        stop.frame = CGRect(x: line.frame.maxX+15, y: 0, width: scheduleViewBounds.width * 0.80, height: height)
        stop.center.y = contentView.center.y
        
        separator.frame = CGRect(x: stop.frame.minX - 5, y: height - 1, width: scheduleViewBounds.width, height: 1)
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: line.center.x,y: contentView.center.y), radius: CGFloat(4.0), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        dot.path = circlePath.cgPath
        dot.fillColor = UIColor.white.cgColor

    }
    
    func configStop(loop: Bool){
        stop.font = loop ? UIFont(name: "HelveticaNeue-Medium", size: 13.0) : UIFont(name: "HelveticaNeue", size: 13.0)
        stop.sizeToFit()
        time.font = loop ? UIFont(name: "HelveticaNeue-Medium", size: 12.0) : UIFont(name: "HelveticaNeue-Light", size: 11.5)
        time.sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
