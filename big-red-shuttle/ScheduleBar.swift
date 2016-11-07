//
//  ScheduleBar.swift
//  big-red-shuttle
//
//  Created by Monica Ong on 11/3/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import UIKit

protocol ScheduleBarDelegate {
    func selectCell(button: UIButton) -> Void
}

class ScheduleBar: UIScrollView {
    private var buttons: [UIButton]!
    private var bar: UIView!
    private var seperator: UIView!
    private var buttonWidth: CGFloat!
    private var buttonPadding: CGFloat = 20
    private var selectedButton: UIButton!
    var delegateSB: ScheduleBarDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUp(buttonsData: [String], selected: Int){
        self.backgroundColor = UIColor.white
        
        buttons = []
        for time in buttonsData{ //set up buttons
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: self.bounds.height))
            button.setTitle(time, for: UIControlState.normal)
            button.setTitleColor(Color.greyedout, for: UIControlState.normal)
            button.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 13.0)
            button.sizeToFit()
            var frameRect: CGRect = button.frame
            buttonWidth = button.bounds.width + buttonPadding
            frameRect.size.width = buttonWidth
            button.frame = frameRect
            button.layer.cornerRadius = button.bounds.height/2
            button.clipsToBounds = true
            button.addTarget(self, action: #selector(self.buttonPressed(button:)), for: UIControlEvents.touchUpInside)
            buttons.append(button)
        }
        print("Button width: \(buttonWidth)")
        for i in 0...(buttons.count-1){ //place buttons
            if i == 0 {
                buttons[i].frame = buttons[i].frame.offsetBy(dx:buttonPadding/2, dy: 0)
            }
            else{
            buttons[i].frame = buttons[i].frame.offsetBy(dx: buttons[i-1].frame.maxX + buttonPadding/2, dy: 0) //CGFloat(i) * buttonWidth + buttonPadding
            }
            print("\(i): \(buttons[i].frame)")
            buttons[i].center.y = (self.bounds.height/2)
            buttons[i].tag = i //tag represents index
            self.addSubview(buttons[i])
        }
        
        self.contentSize = CGSize(width: CGFloat(buttons.count) * (buttons[0].bounds.width + buttonPadding/2) + buttonPadding/2, height: -self.bounds.height - 3.0)
        self.bounces = false
        self.alwaysBounceHorizontal = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        
        seperator = UIView(frame: CGRect(x: 0, y: self.bounds.height - 1.0, width: self.contentSize.width, height: 1))
        seperator.backgroundColor = Color.lightgrey
        self.addSubview(seperator)
        
        bar = UIView(frame: CGRect(x: 0, y: self.bounds.height - 3.0, width: buttons[0].bounds.width + buttonPadding, height: 3.0))
        bar.backgroundColor = Color.red
        selectedButton = buttons[selected]
        select(button: selectedButton, animation: false)
        self.addSubview(bar)
    }
  
    func select(button: UIButton, animation: Bool){
        func moveBar() -> Void{
            bar.frame.origin.x = button.frame.minX - buttonPadding/2
        }
        func changeButton() -> Void{
            selectedButton.setTitleColor(Color.greyedout, for: UIControlState.normal)
            selectedButton.backgroundColor = UIColor.white
            button.setTitleColor(UIColor.white, for: UIControlState.normal)
            selectedButton = button
            button.backgroundColor = Color.red
        }
        if animation {
            UIView.animate(withDuration: 0.5, animations: {
                moveBar()
                changeButton()
            })
        }else{
            moveBar()
            changeButton()
        }
        scrollRectToVisible(CGRect(x: button.frame.minX, y: self.frame.minY, width: button.bounds.width, height: button.bounds.height), animated: true)
    }
    
    func buttonPressed(button: UIButton) -> Void{
        select(button: button, animation: true)
        delegateSB.selectCell(button: button)
    }
    
    //Need to also be able to autoscroll uiscrollview
    //make h scrollbar invisible
    //prevent vertical scrolling
    //grey underline under uiscrollview

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
