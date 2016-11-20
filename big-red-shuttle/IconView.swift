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
    var frameWidth: CGFloat!
    var frameHeight: CGFloat!
    var circleViewDiameter: CGFloat!
    var offset: CGFloat!
    var circleCenter: CGFloat!
    var innerCircleRadiusOffset: CGFloat!
    var triangleHeight: CGFloat!
    var fontSize: CGFloat!
    
    init(frameWidth: CGFloat, frameHeight: CGFloat, circleViewDiameter: CGFloat, offset: CGFloat, innerCircleRadiusOffset: CGFloat, triangleHeight: CGFloat, fontSize: CGFloat) {
        super.init(frame: CGRect(x:0, y:0, width:frameWidth, height:frameHeight))
        
        self.frameWidth = frameWidth
        self.frameHeight = frameHeight
        self.circleViewDiameter = circleViewDiameter
        self.offset = offset
        self.circleCenter = circleViewDiameter / 2.0 + offset
        self.innerCircleRadiusOffset = innerCircleRadiusOffset
        self.triangleHeight = triangleHeight
        self.fontSize = fontSize
        
        backgroundColor = .clear
        clicked = false
        
        //MAIN CIRCLE
        circleView = UIView(frame: CGRect(x:offset, y:offset, width:circleViewDiameter, height:circleViewDiameter))
        circleView.backgroundColor = .iconblack
        circleView.layer.cornerRadius = circleView.frame.size.height / 2.0
        circleView.layer.masksToBounds = true
        circleView.layer.zPosition = 100
        addSubview(circleView)
        
        timeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: circleViewDiameter, height: circleViewDiameter))
        timeLabel.textAlignment = .center
        timeLabel.textColor = .white
        timeLabel.numberOfLines = 0
        timeLabel.font = .systemFont(ofSize: fontSize)
        timeLabel.font = .boldSystemFont(ofSize: fontSize)
        circleView.addSubview(timeLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let yPos = circleViewDiameter + offset + triangleHeight + 4.0
        
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
            arcCenter: CGPoint(x:circleCenter-offset,y:circleCenter-offset),
            radius: CGFloat(circleViewDiameter/2.0 - innerCircleRadiusOffset ),
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
        trianglePath.move(to: CGPoint(x: circleCenter - offset, y: circleViewDiameter))
        trianglePath.addLine(to: CGPoint(x: circleCenter + offset, y: circleViewDiameter))
        trianglePath.addLine(to: CGPoint(x: circleCenter, y: CGFloat(circleViewDiameter + offset) + triangleHeight))
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

class IconViewBig: IconView {
    init() {
        super.init(frameWidth: 55, frameHeight: 75, circleViewDiameter: 50, offset: 2.5, innerCircleRadiusOffset: 4.0, triangleHeight: 3.5, fontSize: 11)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class IconViewSmall: IconView {
    init() {
        super.init(frameWidth: 35, frameHeight: 55, circleViewDiameter: 30, offset: 2.5, innerCircleRadiusOffset: 3.0, triangleHeight: 2.0, fontSize: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let yPos = circleViewDiameter + offset + triangleHeight + 4.0
        
        smallGrayCircle = drawSmallGrayCircle()
        let triangle = drawTriangle()
        let groundBlackCircle = drawCircle(yPos: yPos, radius: 5, color: UIColor.iconblack.cgColor)
        let groundWhiteCircle = drawCircle(yPos: yPos, radius: 8, color: UIColor.iconwhite.cgColor)
        let minus = drawMinus()
        
        smallGrayCircle.zPosition = 101
        minus.zPosition = 101
        triangle.zPosition = 3
        groundBlackCircle.zPosition = 2
        groundWhiteCircle.zPosition = 1
        
        circleView.layer.addSublayer(smallGrayCircle)
        circleView.layer.addSublayer(minus)
        layer.addSublayer(triangle)
        layer.addSublayer(groundBlackCircle)
        layer.addSublayer(groundWhiteCircle)
    }
    
    internal func drawMinus() -> CAShapeLayer {
        let desiredLineWidth:CGFloat = 2    // your desired value
        
        let roundRect = UIBezierPath(roundedRect: CGRect(x: 10, y:circleCenter - 2.0, width: circleViewDiameter - 20, height: 0.5), byRoundingCorners:.allCorners, cornerRadii: CGSize(width: 1.0, height: 1.0))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = roundRect.cgPath
        
        shapeLayer.fillColor = UIColor.iconlightgray.cgColor
        shapeLayer.strokeColor = UIColor.iconlightgray.cgColor
        shapeLayer.lineWidth = desiredLineWidth
        
        return shapeLayer
    }
}

