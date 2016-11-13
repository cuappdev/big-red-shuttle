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
    var smallGrayCircle: CAShapeLayer!
    var clicked: Bool!
    
    //constants
    let circleViewWidth = 50.0
    let circleViewHeight = 50.0
    let offset = 2.5
    let circleCenter = 27.5
    let triangleHeight = 3.5
    
    
    init() {
        super.init(frame: CGRect(x:0, y:0, width:55, height:75))
        
        self.backgroundColor = UIColor(red: 147/255, green: 49/255, blue: 53/255, alpha: 0.0)
        clicked = false
        
        
        //MAIN CIRCLE
        circleView = UIView(frame: CGRect(x:offset, y:offset, width:circleViewWidth, height:circleViewHeight))
        circleView.backgroundColor = UIColor(red: 47/255, green: 49/255, blue: 53/255, alpha: 1.0)
        circleView.layer.cornerRadius = circleView.frame.size.height / 2.0
        circleView.layer.masksToBounds = true
        circleView.layer.zPosition = 100
        self.addSubview(circleView)
        
        timeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: circleViewWidth, height: circleViewHeight))
        timeLabel.textAlignment = .center
        timeLabel.textColor = .white
        timeLabel.numberOfLines = 0
        timeLabel.font = UIFont.systemFont(ofSize: 11)
        timeLabel.font = UIFont.boldSystemFont(ofSize: 11)
        //timeLabel.adjustsFontSizeToFitWidth = true
        circleView.addSubview(timeLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        let yPos = CGFloat(circleViewHeight + offset + triangleHeight + 4.0)
        
        smallGrayCircle = drawSmallGrayCircle()
        let triangle = drawTriangle()
        let groundBlackCircle = drawGroundBlackCircle(yPos: yPos)
        let groundWhiteCirlce = drawGroundWhiteCircle(yPos: yPos)
        let groundRedCircle = drawGroundRedCircle(yPos: yPos)
        
        smallGrayCircle.zPosition = 101
        triangle.zPosition = 3
        groundBlackCircle.zPosition = 2
        groundWhiteCirlce.zPosition = 1
        groundRedCircle.zPosition = 0
        
        circleView.layer.addSublayer(smallGrayCircle)
        self.layer.addSublayer(triangle)
        self.layer.addSublayer(groundBlackCircle)
        self.layer.addSublayer(groundWhiteCirlce)
        self.layer.addSublayer(groundRedCircle)
        
    }
    
    internal func drawSmallGrayCircle() -> CAShapeLayer {
        let desiredLineWidth:CGFloat = 1    // your desired value
        
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x:circleCenter-2.5,y:circleCenter-2.5),
            radius: CGFloat( circleViewWidth/2.0 - 4 ),
            startAngle: CGFloat(0),
            endAngle:CGFloat(M_PI * 2),
            clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor(red: 96/255, green: 99/255, blue: 105/255, alpha: 1.0).cgColor
        shapeLayer.lineWidth = desiredLineWidth
        
        let colorAnim = CABasicAnimation(keyPath: "strokeColor")
        colorAnim.fromValue = shapeLayer.strokeColor
        colorAnim.duration = 1.0
        if !clicked {
            colorAnim.toValue = UIColor(red: 96/255, green: 99/255, blue: 105/255, alpha: 1.0).cgColor
            shapeLayer.strokeColor = UIColor(red: 96/255, green: 99/255, blue: 105/255, alpha: 1.0).cgColor
        } else {
            colorAnim.toValue = UIColor.brsred.cgColor
            shapeLayer.strokeColor = UIColor.brsred.cgColor
        }
        shapeLayer.add(colorAnim, forKey: "colorAnimation")
        
        return shapeLayer
    }
    
    internal func drawTriangle() -> CAShapeLayer {
        let desiredLineWidth:CGFloat = 5    // your desired value
        
        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: circleCenter - offset, y: circleViewHeight))
        trianglePath.addLine(to: CGPoint(x: circleCenter + offset, y: circleViewHeight))
        trianglePath.addLine(to: CGPoint(x: circleCenter, y: circleViewHeight + offset + triangleHeight))
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
            arcCenter: CGPoint(x: CGFloat(circleCenter), y:yPos),
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
            arcCenter: CGPoint(x: CGFloat(circleCenter), y:yPos),
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
            arcCenter: CGPoint(x: CGFloat(circleCenter), y:yPos),
            radius: CGFloat(13),
            startAngle: CGFloat(0),
            endAngle:CGFloat(M_PI * 2),
            clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.brsred.cgColor
        shapeLayer.strokeColor = UIColor.brsred.cgColor
        shapeLayer.lineWidth = desiredLineWidth
        
        return shapeLayer
    }
}
