//
//  ScheduleBar.swift
//  big-red-shuttle
//
//  Created by Monica Ong on 11/3/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import UIKit

protocol ScheduleBarDelegate: class {
    func scrollToCell(button: UIButton)
}

class ScheduleBar: UIScrollView {
    
    let separatorHeight: CGFloat = 1.2
    let buttonHPadding: CGFloat = 16
    let buttonVPadding: CGFloat = 8
    let buttonMargin: CGFloat = 16
    let innerPadding: CGFloat = 5
    
    var timeButtons: [UIButton]!
    var highlight: UIView!
    var separator: UIView!
    var selectedButton: UIButton!
    var isAnimating: Bool!
    weak var sbDelegate: ScheduleBarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp(buttonsData: [String], selected: Int) {
        backgroundColor = .white
        isAnimating = false
        
        var contentWidth: CGFloat = 0
        timeButtons = []
        
        // Set up formatted buttons
        for time in buttonsData {
            let timeStringSize = time.size(withAttributes: [NSAttributedStringKey.font: UIFont(name: "SFUIDisplay-Regular", size: 14)!])
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: timeStringSize.width + 2*buttonHPadding, height: timeStringSize.height + 2*buttonVPadding))
            
            contentWidth += button.frame.width

            button.center.y = bounds.midY
            button.setTitle(time, for: .normal)
            button.setTitleColor(.brsgrey, for: .normal)
            button.titleLabel?.font = UIFont(name: "SFUIText-Semibold", size: 14.0)!
            button.layer.cornerRadius = button.frame.height / 2.0
            button.clipsToBounds = true
            button.addTarget(self, action: #selector(buttonPressed(button:)), for: .touchUpInside)

            timeButtons.append(button)
        }
        
        // Place buttons by correct offset
        for (index, button) in timeButtons.enumerated() {
            let deltaX = (index == 0) ? buttonMargin : timeButtons[index-1].frame.maxX + innerPadding
            button.frame = button.frame.offsetBy(dx: deltaX, dy: 0)
            button.tag = index // tag represents index
            addSubview(button)
        }
 
        contentSize = CGSize(width: contentWidth + 2*buttonMargin + (CGFloat(timeButtons.count - 1) * innerPadding), height: frame.height)
        bounces = false
        alwaysBounceHorizontal = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        separator = UIView(frame: CGRect(x: 0, y: frame.height - separatorHeight, width: contentSize.width, height: separatorHeight))
        separator.backgroundColor = .brsgray
        addSubview(separator)
        
        selectedButton = timeButtons[selected]
        
        highlight = UIView(frame: selectedButton.frame)
        highlight.layer.cornerRadius = selectedButton.frame.height / 2.0
        highlight.clipsToBounds = true
        highlight.backgroundColor = .brsred
        addSubview(highlight)
        sendSubview(toBack: highlight)
        
        select(button: selectedButton, animation: false)
    }
    
    func setButton(asSelected button: UIButton) {
        selectedButton.setTitleColor(.brsgrey, for: .normal)
        button.setTitleColor(.white, for: .normal)
        selectedButton = button
    }
    
    func select(button: UIButton, animation: Bool) {
        let moveSelector = { self.highlight.frame = button.frame }
        setButton(asSelected: button)
        
        if animation {
            UIView.animate(withDuration: 0.25, animations: {
                moveSelector()
                self.scrollRectToVisible(CGRect(x: self.highlight.frame.minX - self.buttonMargin, y: self.highlight.frame.minY,
                                                width: self.highlight.frame.width + 2*self.buttonMargin, height: self.highlight.frame.height),
                                         animated: false)
            })
        } else {
            moveSelector()
        }
    }
    
    @objc func buttonPressed(button: UIButton) {
        select(button: button, animation: true)
        sbDelegate?.scrollToCell(button: button)
    }
    
    func scrollToButton(button: UIButton) {
        select(button: button, animation: true)
    }
    
}
