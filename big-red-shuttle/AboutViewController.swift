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
    
    let kBannerHeight: CGFloat = 200
    let kTextViewPadding: CGFloat = 30
    let kCancelButtonLength: CGFloat = 10
    let kContainerPadding: CGFloat = 10
    
    var delegate: AboutViewDelegate?
    var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 75/255, green: 79/255, blue: 86/255, alpha: 0.5)

        containerView = UIView(frame: CGRect(x: kContainerPadding, y: view.frame.height, width: view.frame.width-2*kContainerPadding, height: view.frame.height-4*kContainerPadding))
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 4
        containerView.clipsToBounds = true
        
        let bannerView = UIView(frame: CGRect(x: 0, y: 0, width: containerView.frame.width, height: kBannerHeight))
        let gradientLayer = CAGradientLayer()
        let firstColor = UIColor(red: 34/255, green: 27/255, blue: 49/255, alpha: 1).cgColor
        let secondColor = UIColor(red: 86/255, green: 105/255, blue: 124/255, alpha: 1.0).cgColor
        gradientLayer.colors = [firstColor, firstColor, secondColor]
        gradientLayer.startPoint = CGPoint(x:0, y:0.5)
        gradientLayer.endPoint = CGPoint(x:1, y:0.5)
        gradientLayer.locations = [0, 0.25, 1]
        gradientLayer.frame = bannerView.frame
        bannerView.layer.insertSublayer(gradientLayer, at: 0)
        containerView.addSubview(bannerView)
        
        let xView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        xView.center = CGPoint(x: bannerView.bounds.midX, y: bannerView.bounds.midY)
        let xPath = UIBezierPath()
        xPath.move(to: CGPoint(x: 0, y: 0))
        xPath.addLine(to: CGPoint(x: 30, y: 30))
        xPath.move(to: CGPoint(x: 30, y: 0))
        xPath.addLine(to: CGPoint(x: 0, y: 30))
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = xPath.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 3
        xView.layer.addSublayer(shapeLayer)
        bannerView.addSubview(xView)
        
        let appdevLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 90, height: 20))
        let appdevString = NSMutableAttributedString(string: "App", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17, weight: UIFontWeightRegular), NSForegroundColorAttributeName: UIColor.white])
        let devString = NSAttributedString(string: "Dev", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17, weight: UIFontWeightSemibold), NSForegroundColorAttributeName: UIColor(red: 80/255, green: 227/255, blue: 194/255, alpha: 1.0)])
        appdevString.append(devString)
        appdevLabel.attributedText = appdevString
        appdevLabel.center = CGPoint(x: xView.frame.midX+50+appdevLabel.frame.width/2, y: xView.frame.midY)
        bannerView.addSubview(appdevLabel)
        
        let brsImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 43, height: 60))
        brsImageView.center = CGPoint(x: xView.frame.midX-50-brsImageView.frame.width/2, y: xView.frame.midY)
        brsImageView.image = #imageLiteral(resourceName: "magnifying-glass") //TODO: add actual BRS image
        bannerView.addSubview(brsImageView)
        
        let exitButton = UIButton(frame: CGRect(x: containerView.frame.width-kCancelButtonLength-16, y: 16,
                                                width: kCancelButtonLength, height: kCancelButtonLength))
        let exitXPath = UIBezierPath()
        exitXPath.move(to: CGPoint(x: 0, y: 0))
        exitXPath.addLine(to: CGPoint(x: kCancelButtonLength, y: kCancelButtonLength))
        exitXPath.move(to: CGPoint(x: kCancelButtonLength, y: 0))
        exitXPath.addLine(to: CGPoint(x: 0, y: kCancelButtonLength))
        let exitShapeLayer = CAShapeLayer()
        exitShapeLayer.path = exitXPath.cgPath
        exitShapeLayer.strokeColor = UIColor(white: 1, alpha: 0.5).cgColor
        exitShapeLayer.lineWidth = 1
        exitButton.layer.addSublayer(exitShapeLayer)
        exitButton.addTarget(self, action: #selector(didTapDismissButton), for: .touchUpInside)
        containerView.addSubview(exitButton)
        
        let textViewContainer = UIView(frame: CGRect(x: kTextViewPadding, y: kBannerHeight+16,
                                                     width: containerView.frame.width-2*kTextViewPadding, height: containerView.frame.height-kBannerHeight-kTextViewPadding))
        let textView = UITextView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: textViewContainer.frame.size))
        textView.isEditable = false
        textView.showsVerticalScrollIndicator = false
        
        let textString = NSMutableAttributedString(string: "\nCollaboration between Big Red Shuttle and AppDev", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold)])
        let collabString = NSAttributedString(string: "\n\nIn order to enable the Big Red Shuttle to help fulfill its mission in providing safe, free, and late-night transportation to the Cornell community, the AppDev project team designed and developed this iOS application.\n\n\n", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)])
        let missionHeader = NSAttributedString(string: "Big Red Shuttle's Mission", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold)])
        let aboutText = "\n\nThe Big Red Shuttle was originally founded in 2011 under the Cornell Women' Resource Center, providing students with free late-night transportation during exam periods. However, the need for additional means of late- night transportation with flexible pick-up and drop-off points has become clear. Our objective is to expand the Big Red Shuttle from an academic-only resource to one that provides safe, timely and free transportation to Cornell students in need of a safe ride home. Our ultimate goal is to promote a safer campus climate to prevent alcohol-related incidents and sexual assault. By expanding the Big Red Shuttle, we strive to cater to Cornell-affiliated undergraduate and graduate students of all genders, sexual orientations, majors, ages, races, national origins and organizational affiliations. Unlike the TCAT or unreliable Ithaca taxi companies, the Big Red Shuttle provides a safe and reliable means of transportation open to all Cornellians. As of Fall 2016, the Big Red Shuttle will run on a 20-minute route every Friday and Saturday from 12am-3am. The schedule for the remainder of Fall can be found below. The driver is a professional, paid employee. Additionally, the Big Red Shuttle has paired with the Campus Activities Office to provide two paid student aides to provide assistance to the shuttle's passengers. Big Red Shuttle believes that these student aides, trained by Cayuga's Watchers, will serve as active bystanders and help ensure the safety of Cornell students.\n\n"
        let aboutString = NSAttributedString(string: aboutText, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)])
        textString.append(collabString)
        textString.append(missionHeader)
        textString.append(aboutString)
        textView.attributedText = textString
        textViewContainer.addSubview(textView)
        let fadeGradient = CAGradientLayer()
        fadeGradient.frame = textViewContainer.bounds
        fadeGradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        fadeGradient.locations = [0.0, 0.05, 0.90, 1.0]
        textViewContainer.layer.mask = fadeGradient
        containerView.addSubview(textViewContainer)
        
        view.addSubview(containerView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let containerFrame = CGRect(x: kContainerPadding, y: 20+kContainerPadding, width: view.frame.width-2*kContainerPadding, height: view.frame.height-4*kContainerPadding)
        UIView.animate(withDuration: 0.25, animations: {
            self.containerView.frame = containerFrame
            }, completion: nil)
    }
    
    func didTapDismissButton() {
        let containerFrame = CGRect(x: kContainerPadding, y: view.frame.height, width: view.frame.width-2*kContainerPadding, height: view.frame.height-4*kContainerPadding)
        UIView.animate(withDuration: 0.25, animations: {
            self.containerView.frame = containerFrame
        }, completion: nil)
        dismiss(animated: true, completion: nil)
    }
}
