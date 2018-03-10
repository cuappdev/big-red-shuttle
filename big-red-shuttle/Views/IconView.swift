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
    
    var circleViewDiameter: CGFloat!
    var innerCircleRadiusOffset: CGFloat!
    var maxScale: CGFloat!
    var yOffset: CGFloat!
    var yGroundOffset: CGFloat!
    var triangleWidthScale: CGFloat!
    var fontSize: CGFloat!
    var edgePadding: CGFloat!
    var yGroundPos: CGFloat!
    
    init(circleViewDiameter: CGFloat, innerCircleRadiusOffset: CGFloat, maxScale: CGFloat, yOffset: CGFloat, yGroundOffset: CGFloat, triangleWidthScale: CGFloat, fontSize: CGFloat) {
        super.init(frame: CGRect(x: 0, y: 0, width: maxScale * circleViewDiameter, height: 1.5*circleViewDiameter + yOffset))

        self.circleViewDiameter = circleViewDiameter
        self.innerCircleRadiusOffset = innerCircleRadiusOffset
        self.maxScale = maxScale
        self.yOffset = yOffset
        self.yGroundOffset = yGroundOffset
        self.triangleWidthScale = triangleWidthScale
        self.fontSize = fontSize
        self.edgePadding = (frame.width - circleViewDiameter) / 2.0
        
        backgroundColor = .clear
        clicked = false
        
        // Main Circle
        circleView = UIView(frame: CGRect(x: edgePadding, y: edgePadding + yOffset, width: circleViewDiameter, height: circleViewDiameter))
        circleView.backgroundColor = .iconblack
        circleView.layer.cornerRadius = circleView.frame.height / 2.0
        circleView.layer.masksToBounds = true
        circleView.layer.zPosition = 100
        addSubview(circleView)
        
        timeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: circleViewDiameter, height: circleViewDiameter))
        timeLabel.font = UIFont(name: "SFUIDisplay-Semibold", size: fontSize)
        timeLabel.textAlignment = .center
        timeLabel.textColor = .white
        timeLabel.numberOfLines = 0
        circleView.addSubview(timeLabel)
        
        self.yGroundPos = circleView.frame.midY + (0.55 * circleViewDiameter)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        smallGrayCircle = drawSmallGrayCircle()
        
        let triangle = drawTriangle()
        let groundBlackCircle = drawCircle(radius: 3, color: UIColor.iconblack.cgColor)
        let groundWhiteCircle = drawCircle(radius: 5, color: UIColor.white.cgColor)
        
        smallGrayCircle.zPosition = 101
        triangle.zPosition = 3
        groundBlackCircle.zPosition = 2
        groundWhiteCircle.zPosition = 1
        
        circleView.layer.addSublayer(smallGrayCircle)
        layer.addSublayer(triangle)
        layer.addSublayer(groundBlackCircle)
        layer.addSublayer(groundWhiteCircle)
    }
    
    internal func setClicked(clicked: Bool) {
        self.clicked = clicked
        smallGrayCircle.strokeColor = clicked ? UIColor.brsred.cgColor : UIColor.iconlightgray.cgColor
    }
    
    internal func drawSmallGrayCircle() -> CAShapeLayer {
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: circleView.frame.midX - edgePadding, y: circleView.frame.midY - edgePadding - yOffset),
            radius: CGFloat(circleViewDiameter/2.0 - innerCircleRadiusOffset),
            startAngle: CGFloat(0),
            endAngle: CGFloat(Double.pi * 2),
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
        let desiredLineWidth: CGFloat = 5
        
        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: frame.midX - (triangleWidthScale * circleViewDiameter), y: circleView.frame.midY + circleViewDiameter/4))
        trianglePath.addLine(to: CGPoint(x: frame.midX + (triangleWidthScale * circleViewDiameter), y: circleView.frame.midY + circleViewDiameter/4))
        trianglePath.addLine(to: CGPoint(x: frame.midX , y: yGroundPos))
        trianglePath.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = trianglePath.cgPath
        shapeLayer.fillColor = UIColor.iconblack.cgColor
        shapeLayer.strokeColor = UIColor.iconblack.cgColor
        shapeLayer.lineWidth = desiredLineWidth
        
        return shapeLayer
    }
    
    internal func drawCircle(radius: CGFloat, color: CGColor) -> CAShapeLayer {
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: frame.midX, y: CGFloat(yGroundPos) + CGFloat(yGroundOffset) + CGFloat(edgePadding)),
            radius: CGFloat(radius),
            startAngle: CGFloat(0),
            endAngle: CGFloat(Double.pi * 2),
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
        super.init(circleViewDiameter: 44, innerCircleRadiusOffset: 3.0, maxScale: 1.2, yOffset: 5.0, yGroundOffset: 0, triangleWidthScale: 0.22, fontSize: 11)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

class IconViewSmall: IconView {
    
    init() {
        super.init(circleViewDiameter: 32, innerCircleRadiusOffset: 2.4, maxScale: 1.1, yOffset: 2.0, yGroundOffset: 1.0, triangleWidthScale: 0.14, fontSize: 0)
        timeLabel.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let minus = drawMinus()
        minus.zPosition = 101
        circleView.layer.addSublayer(minus)
    }
    
    internal func drawMinus() -> CAShapeLayer {
        let desiredLineWidth: CGFloat = 2
        let roundRect = UIBezierPath(roundedRect: CGRect(x: circleViewDiameter * 0.35, y: frame.midX - edgePadding, width: circleViewDiameter * 0.3, height: 0.5), byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 1.0, height: 1.0))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = roundRect.cgPath
        shapeLayer.fillColor = UIColor.iconlightgray.cgColor
        shapeLayer.strokeColor = UIColor.iconlightgray.cgColor
        shapeLayer.lineWidth = desiredLineWidth
        
        return shapeLayer
    }
    
}
