//
//  ScheduleBar.swift
//  big-red-shuttle
//
//  Created by Monica Ong on 11/3/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import UIKit

protocol ScheduleBarDelegate: class {
    func scrollToCell(button: UIButton) -> Void
}

class ScheduleBar: UIScrollView {
    var buttons: [UIButton]!
    var oval: UIView!
    var separator: UIView!
    var buttonWidth: CGFloat!
    var buttonPadding: CGFloat = 20
    var selectedButton: UIButton!
    weak var delegateSB: ScheduleBarDelegate?
    var backwards: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp(buttonsData: [String], selected: Int){
        backgroundColor = .white
        
        buttons = []
        for time in buttonsData{ //set up buttons
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: frame.height))
            button.setTitle(time, for: .normal)
            button.setTitleColor(.brsgreyedout, for: .normal)
            button.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 13.0)
            button.sizeToFit()
            //Make oval background view behind button
            buttonWidth = button.frame.width + buttonPadding
            button.frame.size.width = buttonWidth
            button.layer.cornerRadius = button.frame.height/2.0
            button.clipsToBounds = true
            button.addTarget(self, action: #selector(buttonPressed(button:)), for: .touchUpInside)
            buttons.append(button)
        }
        for i in 0..<buttons.count{ //place buttons
            if i == 0 {
                buttons[i].frame = buttons[i].frame.offsetBy(dx:buttonPadding/2.0, dy: 0)
            } else{
                buttons[i].frame = buttons[i].frame.offsetBy(dx: buttons[i-1].frame.maxX + buttonPadding/2.0, dy: 0)
            }
            buttons[i].center.y = (frame.height/2.0)
            buttons[i].tag = i //tag represents index
            addSubview(buttons[i])
        }
        contentSize = CGSize(width: CGFloat(buttons.count) * (buttons[0].frame.width + buttonPadding/2.0), height: frame.height)
        contentOffset = CGPoint(x: 0, y: -frame.height - 3.0)
        bounces = false
        alwaysBounceHorizontal = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        separator = UIView(frame: CGRect(x: 0, y: frame.height - 1.0, width: contentSize.width, height: 1))
        separator.backgroundColor = .brslightgrey
        addSubview(separator)
        
        oval = UIView(frame: buttons[0].frame)
        oval.layer.cornerRadius = buttons[0].frame.height/2.0
        oval.clipsToBounds = true
        oval.backgroundColor = .brsred
        addSubview(oval)
        sendSubview(toBack: oval)
        
        selectedButton = buttons[selected]
        buttonPressed(button: selectedButton)
        
    }
    
    func setButton(asSelected button: UIButton){
        let oldSelectedIndex = buttons.index(of: selectedButton)!
        let newSelectedIndex = buttons.index(of: button)!
        backwards = (newSelectedIndex < oldSelectedIndex)
        selectedButton.setTitleColor(.brsgreyedout, for: .normal)
        button.setTitleColor(.white, for: .normal)
        selectedButton = button
    }
    
    func select(button: UIButton, animation: Bool){
        let moveSelector = {self.oval.frame.origin.x = button.frame.minX}
        if animation {
            UIView.animate(withDuration: 0.3, animations: {
                moveSelector()
            })
            UIView.transition(with: button, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.setButton(asSelected: button)
            }, completion: nil)
        }else{
            moveSelector()
            setButton(asSelected: button)
        }
        let x = backwards ? (button.frame.minX - buttonPadding): button.frame.maxX
        scrollRectToVisible(CGRect(x: x, y: frame.minY, width: button.frame.width, height: button.frame.height), animated: true)
        
    }
    
    func buttonPressed(button: UIButton) -> Void{
        print("buttonPressed called")
        select(button: button, animation: true)
        print("buttonPressed select")
        delegateSB?.scrollToCell(button: button)
        print("buttonPressed scrolltoCell")
    }

}
