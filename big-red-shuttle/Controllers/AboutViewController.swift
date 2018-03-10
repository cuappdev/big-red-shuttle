//
//  AboutView.swift
//  big-red-shuttle
//
//  Created by Kevin Greer on 11/9/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import UIKit

protocol AboutViewDelegate {
    func didTapAboutViewDismiss()
}

class AboutViewController: UIViewController {
    
    let kTopPadding: CGFloat = 20
    let kContainerPadding: CGFloat = 16
    let kBannerHeight: CGFloat = 160
    let kTextViewPadding: CGFloat = 30
    let kExitButtonLength: CGFloat = 11
    let kExitButtonHitLength: CGFloat = 44
    
    var delegate: AboutViewDelegate?
    var containerView: UIView!
    var aboutSections: [AboutSection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .brscoverviewgray
        aboutSections = getAboutSections()
        
        containerView = UIView(frame: CGRect(x: kContainerPadding, y: view.frame.height, width: view.frame.width - 2*kContainerPadding, height: view.frame.height - 4*kContainerPadding))
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 4
        containerView.clipsToBounds = true
        
        let bannerView = UIView(frame: CGRect(x: 0, y: 0, width: containerView.frame.width, height: kBannerHeight))
        let gradientLayer = CAGradientLayer()
        let startColor = UIColor.aboutviewdarkgray.cgColor
        let endColor = UIColor.aboutviewblue.cgColor
        gradientLayer.colors = [startColor, endColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = bannerView.frame
        bannerView.layer.insertSublayer(gradientLayer, at: 0)
        containerView.addSubview(bannerView)
        
        let crossImageView = UIImageView(image: #imageLiteral(resourceName: "CrossIcon"))
        crossImageView.frame.size = CGSize(width: 24.0, height: 24.0)
        crossImageView.center = bannerView.center
        bannerView.addSubview(crossImageView)
        
        let brsImageView = UIImageView(image: #imageLiteral(resourceName: "BRSLogo"))
        brsImageView.frame.size = CGSize(width: 62.0, height: 45.0)
        brsImageView.center = CGPoint(x: crossImageView.frame.midX - brsImageView.frame.width/2 - 40, y: crossImageView.frame.midY)
        bannerView.addSubview(brsImageView)
        
        let appdevImageView = UIImageView(image: #imageLiteral(resourceName: "AppDevRedLogo"))
        appdevImageView.frame.size = CGSize(width: 45.0, height: 45.0)
        appdevImageView.center = CGPoint(x: crossImageView.frame.midX + appdevImageView.frame.width/2 + 40, y: crossImageView.frame.midY)
        bannerView.addSubview(appdevImageView)
        
        let exitImageView = UIImageView(image: #imageLiteral(resourceName: "ExitIcon"))
        exitImageView.frame = CGRect(x: containerView.frame.width - kContainerPadding - kExitButtonLength, y: kContainerPadding, width: kExitButtonLength, height: kExitButtonLength)
        containerView.addSubview(exitImageView)
        
        let exitButton = UIButton(frame: CGRect(x: containerView.frame.width - kExitButtonHitLength, y: 0, width: kExitButtonHitLength, height: kExitButtonHitLength))
        exitButton.backgroundColor = .clear
        exitButton.addTarget(self, action: #selector(didTapDismissButton), for: .touchUpInside)
        containerView.addSubview(exitButton)
        
        let textViewContainer = UIView(frame: CGRect(x: kTextViewPadding, y: kBannerHeight + kTextViewPadding/2, width: containerView.frame.width - 2*kTextViewPadding, height: containerView.frame.height - kBannerHeight - kTextViewPadding))
        let textView = UITextView(frame: CGRect(origin: .zero, size: textViewContainer.frame.size))
        textView.isEditable = false
        textView.showsVerticalScrollIndicator = false
        
        let textString = NSMutableAttributedString()
        
        for (index, aboutSection) in aboutSections.enumerated() {
            if index == 0 {
                let topPaddingString = NSAttributedString(string: "\n", attributes: [NSAttributedStringKey.font: UIFont(name: "SFUIDisplay-Semibold", size: 6)!])
                textString.append(topPaddingString)
            }
            
            let titleString = NSAttributedString(string: "\(aboutSection.title)\n", attributes: [NSAttributedStringKey.font: UIFont(name: "SFUIDisplay-Semibold", size: 16)!])
            textString.append(titleString)
            
            let spacingString = NSAttributedString(string: "\n", attributes: [NSAttributedStringKey.font: UIFont(name: "SFUIDisplay-Semibold", size: 11)!])
            textString.append(spacingString)
            
            let linkText = "\(aboutSection.title) Website"
            let summaryText = aboutSection.link.isEmpty ? "\(aboutSection.summary)\n" : "\(aboutSection.summary) Learn more at the \(linkText).\n"
            let summaryString = NSMutableAttributedString(string: summaryText, attributes: [NSAttributedStringKey.font: UIFont(name: "SFUIDisplay-Regular", size: 14)!])
            summaryString.hyperlink(text: "\(linkText)", linkURL: "\(aboutSection.link)")
            textString.append(summaryString)
            
            if index != aboutSections.count - 1 {
                let dividerString = NSAttributedString(string: "\n", attributes: [NSAttributedStringKey.font: UIFont(name: "SFUIDisplay-Semibold", size: 25)!])
                textString.append(dividerString)
            }
        }
        
        textString.addAttribute(NSAttributedStringKey.kern, value: CGFloat(0.4), range: NSRange(location: 0, length: textString.length))
        textString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.brsblack, range: NSRange(location: 0, length: textString.length))
        textView.attributedText = textString
        textViewContainer.addSubview(textView)
        
        let fadeGradient = CAGradientLayer()
        fadeGradient.frame = textViewContainer.bounds
        fadeGradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        fadeGradient.locations = [0.0, 0.05, 0.92, 1.0]
        textViewContainer.layer.mask = fadeGradient
        containerView.addSubview(textViewContainer)
        
        view.addSubview(containerView)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanContainerView(sender:)))
        containerView.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let containerFrame = CGRect(x: kContainerPadding, y: kTopPadding + kContainerPadding, width: view.frame.width - 2*kContainerPadding, height: view.frame.height - 4*kContainerPadding)
        UIView.animate(withDuration: 0.25, animations: {
            self.containerView.frame = containerFrame
        })
    }
    
    @objc func didTapDismissButton() {
        let containerFrame = CGRect(x: kContainerPadding, y: view.frame.height, width: view.frame.width - 2*kContainerPadding, height: view.frame.height - 4*kContainerPadding)
        UIView.animate(withDuration: 0.25, animations: {
            self.containerView.frame = containerFrame
        })
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didPanContainerView(sender: UIPanGestureRecognizer) {
        let deltaY = sender.translation(in: view).y
        containerView.frame = CGRect(origin: CGPoint(x: kContainerPadding, y: containerView.frame.minY + deltaY), size: containerView.frame.size)
        sender.setTranslation(.zero, in: view)
        
        if sender.state == .ended {
            let lowEnoughToDismiss = containerView.frame.minY > kContainerPadding + 100
            if lowEnoughToDismiss {
                didTapDismissButton()
            } else {
                let newFrame = CGRect(x: kContainerPadding, y: kTopPadding + kContainerPadding, width: view.frame.width - 2*kContainerPadding, height: view.frame.height - 4*kContainerPadding)
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                    self.containerView.frame = newFrame
                })
            }
        }
    }
    
}
