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
    var clicked: Bool?
    
    //constants
    let frameWidth = 55.0
    let frameHeight = 75.0
    let circleViewWidth = 50.0
    let circleViewHeight = 50.0
    let offset = 2.5
    let circleCenter = 27.5
    let triangleHeight = 3.5
    
    
    init() {
        super.init(frame: CGRect(x:0, y:0, width:frameWidth, height:frameHeight))
        
        backgroundColor = .clear
        clicked = false
        
        //MAIN CIRCLE
        circleView = UIView(frame: CGRect(x:offset, y:offset, width:circleViewWidth, height:circleViewHeight))
        circleView.backgroundColor = .iconblack
        circleView.layer.cornerRadius = circleView.frame.size.height / 2.0
        circleView.layer.masksToBounds = true
        circleView.layer.zPosition = 100
        addSubview(circleView)
        
        timeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: circleViewWidth, height: circleViewHeight))
        timeLabel.textAlignment = .center
        timeLabel.textColor = .white
        timeLabel.numberOfLines = 0
        timeLabel.font = .systemFont(ofSize: 11)
        timeLabel.font = .boldSystemFont(ofSize: 11)
        circleView.addSubview(timeLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let yPos = CGFloat(circleViewHeight + offset + triangleHeight + 4.0)
        
        smallGrayCircle = drawSmallGrayCircle()
        let triangle = drawTriangle()
        let groundBlackCircle = drawCircle(yPos: yPos, radius: 5, color: UIColor.iconblack.cgColor)
        let groundWhiteCircle = drawCircle(yPos: yPos, radius: 8, color: UIColor.iconwhite.cgColor)
        let groundRedCircle = drawCircle(yPos: yPos, radius: 13, color: UIColor.brsred.cgColor)
        
        smallGrayCircle.zPosition = 101
        triangle.zPosition = 3
        groundBlackCircle.zPosition = 2
        groundWhiteCircle.zPosition = 1
        groundRedCircle.zPosition = 0
        
        circleView.layer.addSublayer(smallGrayCircle)
        layer.addSublayer(triangle)
        layer.addSublayer(groundBlackCircle)
        layer.addSublayer(groundWhiteCircle)
        layer.addSublayer(groundRedCircle)
    }
    
    internal func drawSmallGrayCircle() -> CAShapeLayer {
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x:circleCenter-2.5,y:circleCenter-2.5),
            radius: CGFloat( circleViewWidth/2.0 - 4 ),
            startAngle: CGFloat(0),
            endAngle:CGFloat(M_PI * 2),
            clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.iconlightgray.cgColor
        shapeLayer.lineWidth = 1
        
        let colorAnim = CABasicAnimation(keyPath: "strokeColor")
        colorAnim.fromValue = shapeLayer.strokeColor
        colorAnim.duration = 1.0
        colorAnim.toValue = clicked! ? UIColor.brsred.cgColor : UIColor.iconlightgray.cgColor
        shapeLayer.strokeColor = clicked! ? UIColor.brsred.cgColor : UIColor.iconlightgray.cgColor
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
        
        shapeLayer.fillColor = UIColor.iconblack.cgColor
        shapeLayer.strokeColor = UIColor.iconblack.cgColor
        shapeLayer.lineWidth = desiredLineWidth
        
        return shapeLayer
    }
    
    internal func drawCircle(yPos:CGFloat, radius:CGFloat, color:CGColor) -> CAShapeLayer {
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: CGFloat(circleCenter), y:yPos),
            radius: CGFloat(radius),
            startAngle: CGFloat(0),
            endAngle:CGFloat(M_PI * 2),
            clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = color
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 1
        
        return shapeLayer
    }
}
