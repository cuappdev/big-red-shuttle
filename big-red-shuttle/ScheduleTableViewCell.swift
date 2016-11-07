//
//  ScheduleTableViewCell.swift
//  
//
//  Created by Monica Ong on 11/2/16.
//
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {
    
    public var stop: UILabel = UILabel()
    public var time: UILabel = UILabel()
    public var dot: CAShapeLayer = CAShapeLayer()
    private var map: UIButton = UIButton()
    private var line: UIView = UIView()
    private var seperator: UIView = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.isUserInteractionEnabled = false

        line.backgroundColor = Color.red

        time.font = UIFont(name: "HelveticaNeue-Light", size: 11.5)
        time.textColor = Color.black
        
        stop.font = UIFont(name: "HelveticaNeue", size: 13.0)
        stop.textColor = Color.black
        
        map.setTitle("Map", for: UIControlState.normal)
        map.setTitleColor(Color.grey, for: UIControlState.normal)
        map.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 11.3)
        map.setImage(UIImage(named: "pin"), for: UIControlState.normal)
        
        seperator.backgroundColor = Color.lightgrey
        
        dot.strokeColor = Color.red.cgColor
        dot.lineWidth = 3.0
        
        self.contentView.addSubview(stop)
        self.contentView.addSubview(line)
        self.contentView.addSubview(time)
        self.contentView.addSubview(map)
        self.contentView.addSubview(map)
        self.contentView.addSubview(seperator)
        self.contentView.layer.addSublayer(dot)
    }
    
    override func layoutSubviews() {
        let scheduleViewBounds = UIScreen.main.bounds
        
        let height = self.contentView.bounds.height
        
        line.frame = CGRect(x: scheduleViewBounds.width * 0.20, y: 0, width: 3.5, height: height)

        time.center.y = self.contentView.center.y
        time.center.x = scheduleViewBounds.width * 0.10
        
        stop.frame = CGRect(x: line.frame.maxX+15, y: 0, width: scheduleViewBounds.width * 0.80, height: height)
        stop.center.y = self.contentView.center.y
        
        seperator.frame = CGRect(x: stop.frame.minX - 5, y: height - 1, width: scheduleViewBounds.width, height: 1)
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: line.center.x,y: self.contentView.center.y), radius: CGFloat(4.0), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        dot.path = circlePath.cgPath
    }
    
    func configDot(filled: Bool){
        if filled{
            time.font = UIFont(name: "HelveticaNeue-Medium", size: 12.0)
            time.sizeToFit()
            dot.fillColor = Color.red.cgColor
        }else{
            time.font = UIFont(name: "HelveticaNeue-Light", size: 11.5)
            time.sizeToFit()
            dot.fillColor = UIColor.white.cgColor
        }
        
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
