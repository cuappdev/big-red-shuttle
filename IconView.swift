//
//  IconView.swift
//
//
//  Created by Emily Lien on 11/9/16.
//
//

import UIKit

class IconView: UIView {
    var timeLabel: UILabel!
    var circleView: UIView!
    var clicked: Bool!
    
    //constants
    let circleViewWidth = 50.0
    let circleViewHeight = 50.0
    let triangleHeight = 3.5
    
    
    init() {
        super.init(frame: CGRect(x:0, y:0, width:50, height:75))
        
        self.backgroundColor = UIColor(red: 47/255, green: 49/255, blue: 53/255, alpha: 0.0)
        clicked = false
        
        if !clicked {
            //MAIN CIRCLE
            print("init circle view")
            //                    circleView = UIButton(frame: CGRect(x:0, y:0, width:circleViewWidth, height:circleViewHeight))
            //                    circleView.backgroundColor = UIColor(red: 47/255, green: 49/255, blue: 53/255, alpha: 1.0)
            //                    circleView.layer.cornerRadius = circleView.frame.size.height / 2.0
            //                    circleView.layer.masksToBounds = true
            //                    circleView.layer.zPosition = 100
            //
            //
            //
            //                    circleView.setTitle("12:08", for: .normal)
            //
            //                    circleView.titleLabel?.textColor = .white
            //                    circleView.titleLabel?.numberOfLines = 0
            //                    circleView.titleLabel?.font = UIFont.systemFont(ofSize: 11)
            //                    circleView.titleLabel?.font = UIFont.boldSystemFont(ofSize: 11)
            //            self.addSubview(circleView)
            //timeLabel.adjustsFontSizeToFitWidth = true
            
            
            
            circleView = UIView(frame: CGRect(x:0, y:0, width:circleViewWidth, height:circleViewHeight))
            circleView.backgroundColor = UIColor(red: 47/255, green: 49/255, blue: 53/255, alpha: 1.0)
            circleView.layer.cornerRadius = circleView.frame.size.height / 2.0
            circleView.layer.masksToBounds = true
            circleView.layer.zPosition = 100
            self.addSubview(circleView)
            
            timeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: circleViewWidth, height: circleViewHeight/3.0))
            timeLabel.center = circleView.center
            timeLabel.text = "12:08"
            timeLabel.textAlignment = .center
            timeLabel.textColor = .white
            timeLabel.numberOfLines = 0
            timeLabel.font = UIFont.systemFont(ofSize: 11)
            timeLabel.font = UIFont.boldSystemFont(ofSize: 11)
            timeLabel.adjustsFontSizeToFitWidth = true
            circleView.addSubview(timeLabel)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        print("in draw")
        if !clicked {
            print("not clicked drawing")
        let yPos = CGFloat(circleViewHeight + triangleHeight + 4.0)
            
        let smallGrayCircle = drawSmallGrayCircle()
        let triangle = drawTriangle()
        let groundBlackCircle = drawGroundBlackCircle(yPos: yPos)
        let groundWhiteCirlce = drawGroundWhiteCircle(yPos: yPos)
        let groundRedCircle = drawGroundRedCircle(yPos: yPos)
    
        smallGrayCircle.zPosition = 200
        triangle.zPosition = 3
        groundBlackCircle.zPosition = 2
        groundWhiteCirlce.zPosition = 1
        groundRedCircle.zPosition = 0
    
        self.layer.addSublayer(smallGrayCircle)
        self.layer.addSublayer(triangle)
        self.layer.addSublayer(groundBlackCircle)
        self.layer.addSublayer(groundWhiteCirlce)
        self.layer.addSublayer(groundRedCircle)
        }
    }
    
    internal func drawSmallGrayCircle() -> CAShapeLayer {
        let halfSize:CGFloat = min( self.frame.size.width/2, bounds.size.height/2)
        let desiredLineWidth:CGFloat = 1    // your desired value
        
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x:halfSize,y:halfSize),
            radius: CGFloat( halfSize - 4 ),
            startAngle: CGFloat(0),
            endAngle:CGFloat(M_PI * 2),
            clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor(red: 96/255, green: 99/255, blue: 105/255, alpha: 1.0).cgColor
        shapeLayer.lineWidth = desiredLineWidth
        
        return shapeLayer
    }
    
    internal func drawTriangle() -> CAShapeLayer {
        let desiredLineWidth:CGFloat = 5    // your desired value
        
        let trianglePath = UIBezierPath()
        let mid = circleViewWidth / 2.0
        trianglePath.move(to: CGPoint(x: mid - 2.5, y: circleViewHeight))
        trianglePath.addLine(to: CGPoint(x: mid + 2.5, y: circleViewHeight))
        trianglePath.addLine(to: CGPoint(x: mid, y: circleViewHeight + triangleHeight))
        trianglePath.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = trianglePath.cgPath
        
        shapeLayer.fillColor = UIColor(red: 47/255, green: 49/255, blue: 53/255, alpha: 1.0).cgColor
        shapeLayer.strokeColor = UIColor(red: 47/255, green: 49/255, blue: 53/255, alpha: 1.0).cgColor
        shapeLayer.lineWidth = desiredLineWidth
        
        return shapeLayer
    }
    
    internal func drawGroundBlackCircle(yPos:CGFloat) -> CAShapeLayer {
        let desiredLineWidth:CGFloat = 1    // your desired value
        
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: self.frame.size.width/2.0, y:yPos),
            radius: CGFloat(5),
            startAngle: CGFloat(0),
            endAngle:CGFloat(M_PI * 2),
            clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.black.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = desiredLineWidth
        
        return shapeLayer
    }
    
    internal func drawGroundWhiteCircle(yPos:CGFloat) -> CAShapeLayer {
        let desiredLineWidth:CGFloat = 1    // your desired value
        
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: self.frame.size.width/2.0, y:yPos),
            radius: CGFloat(8),
            startAngle: CGFloat(0),
            endAngle:CGFloat(M_PI * 2),
            clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1.0).cgColor
        shapeLayer.strokeColor = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1.0).cgColor
        shapeLayer.lineWidth = desiredLineWidth
        
        return shapeLayer
    }
    
    internal func drawGroundRedCircle(yPos:CGFloat) -> CAShapeLayer {
        let desiredLineWidth:CGFloat = 1    // your desired value
        
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: self.frame.size.width/2.0, y:yPos),
            radius: CGFloat(13),
            startAngle: CGFloat(0),
            endAngle:CGFloat(M_PI * 2),
            clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor(red: 206/255, green: 73/255, blue: 55/255, alpha: 1.0).cgColor
        shapeLayer.strokeColor = UIColor(red: 206/255, green: 73/255, blue: 55/255, alpha: 1.0).cgColor
        shapeLayer.lineWidth = desiredLineWidth
        
        return shapeLayer
    }
}
