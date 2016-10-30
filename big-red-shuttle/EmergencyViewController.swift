//
//  EmergencyViewController.swift
//  big-red-shuttle
//
//  Created by Austin Astorga on 10/26/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import UIKit

class EmergencyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    let emergencyArray = [("Cornell Univeristy Police", 6072551111), ("Emergency Services", 911), ("Blue Light Escorts", 6072557373), ("Gannett Health Services", 6072555155)] //add more later
    var heightForCalculations: CGFloat = 0.0
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navItem = UINavigationItem(title: "Emergency")
        navigationController?.navigationBar.setItems([navItem], animated: false)
        
        // Do any additional setup after loading the view.
        let tableViewFrame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - (tabBarController?.tabBar.frame.height)!)
        
        self.tableView = UITableView(frame: tableViewFrame, style: .plain)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0)
        
        tabBarController?.tabBar.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0)

        self.view.addSubview(self.tableView)
        
        heightForCalculations = view.bounds.height - (tabBarController?.tabBar.frame.height)!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*phoneNumberToFormattedString takes in an integer and converts it to a (XXX) YYY-YYYY string */
    func phoneNumberToFormattedString(phoneNumber: Int) -> String {
        var stringOfPhoneNumber = String(describing: phoneNumber)
        if stringOfPhoneNumber.characters.count == 10 {
            let startIndex = stringOfPhoneNumber.startIndex
            stringOfPhoneNumber.insert("(", at: startIndex)
            print(stringOfPhoneNumber)
            stringOfPhoneNumber.insert(")", at: stringOfPhoneNumber.index(startIndex, offsetBy: 4))
            stringOfPhoneNumber.insert(" ", at: stringOfPhoneNumber.index(startIndex, offsetBy: 5))
            stringOfPhoneNumber.insert("-", at: stringOfPhoneNumber.index(startIndex, offsetBy: 9))
            
            return stringOfPhoneNumber
        } else{
            
            return stringOfPhoneNumber
        }
    }
    
    
    /* draws the outer eye shape. Still needs refinement*/
    func drawOuterEye(eyeShapePath: UIBezierPath, cellHeight: CGFloat) {
        
        eyeShapePath.move(to: CGPoint(x: view.frame.midX - ((view.frame.maxX * 0.12333)/2), y: 0.30 * cellHeight))
        
        eyeShapePath.addCurve(to: CGPoint(x: view.frame.midX + ((view.frame.maxX * 0.12333)/2), y: 0.30 * cellHeight), controlPoint1: CGPoint(x: view.frame.midX, y: ((0.30 * cellHeight) - 20)), controlPoint2: CGPoint(x: view.frame.midX, y: ((0.30 * cellHeight) - 20)))
        
        eyeShapePath.move(to: CGPoint(x: view.frame.midX + ((view.frame.maxX * 0.12333)/2), y: 0.30 * cellHeight))
        
        eyeShapePath.addCurve(to: CGPoint(x: view.frame.midX - ((view.frame.maxX * 0.12333)/2), y: 0.30 * cellHeight), controlPoint1:  CGPoint(x: view.frame.midX, y: ((0.30 * cellHeight) + 20)), controlPoint2: CGPoint(x: view.frame.midX, y: ((0.30 * cellHeight) + 20)))
        
    }
    
    //MARK: tableview functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return emergencyArray.count
        }
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //create everything for first cell 
        //MARK: TODO - make drawing functions separate and call them to keep this concise
        if indexPath.section == 0 {
            let cell = UITableViewCell()
            let cellHeight = heightForCalculations * 0.36
            
            //small red circle
            let littleRedCirlcePath = UIBezierPath()
            littleRedCirlcePath.addArc(withCenter: CGPoint(x: view.frame.midX, y:(0.30 * cellHeight)), radius: 6, startAngle: 0, endAngle: 2.0*3.14, clockwise: true)
        
            //outer eye shape
            let eyeShapePath = UIBezierPath()
            drawOuterEye(eyeShapePath: eyeShapePath, cellHeight: cellHeight)
            
            //color layers
            let innerCircleLayer = CAShapeLayer()
            innerCircleLayer.path = littleRedCirlcePath.cgPath
            innerCircleLayer.strokeColor = UIColor(red:0.83, green:0.29, blue:0.24, alpha:1.0).cgColor
            innerCircleLayer.lineWidth = 4
            innerCircleLayer.fillColor = UIColor.clear.cgColor

            let eyeShapeLayer = CAShapeLayer()
            eyeShapeLayer.path = eyeShapePath.cgPath
            eyeShapeLayer.strokeColor = UIColor(red:0.83, green:0.29, blue:0.24, alpha:1.0).cgColor
            eyeShapeLayer.lineWidth = 4
            eyeShapeLayer.fillColor = UIColor.clear.cgColor
            
            //Safety Label
            let safetyLabel = UILabel()
            safetyLabel.text = "Safety is our mission"
            safetyLabel.font = UIFont.boldSystemFont(ofSize: 20)
            safetyLabel.sizeToFit()
            safetyLabel.center = CGPoint(x: view.frame.midX, y: cellHeight * 0.50)
            
            //Safety Detail Label
            let safetyLabelDetail = UILabel(frame: CGRect(x: safetyLabel.frame.minX - 15, y: cellHeight * 70, width: safetyLabel.frame.maxX + 30, height: 10))
            safetyLabelDetail.textAlignment = .center
            safetyLabelDetail.text = "If there is an emergency, please call the appropriate service."
            safetyLabelDetail.font = UIFont.systemFont(ofSize: 17)
            safetyLabelDetail.textColor = UIColor.lightGray
            safetyLabelDetail.numberOfLines = 2
            safetyLabelDetail.sizeToFit()
            safetyLabelDetail.center = CGPoint(x: view.frame.midX, y: cellHeight * 0.70)
            
            //add layers/views to cell
            cell.layer.addSublayer(innerCircleLayer)
            cell.layer.addSublayer(eyeShapeLayer)
            cell.addSubview(safetyLabel)
            cell.addSubview(safetyLabelDetail)
            
            cell.isUserInteractionEnabled = false
            
            return cell
        }
        else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "emergencyCell")
            cell.textLabel?.text = emergencyArray[indexPath.row].0
            cell.detailTextLabel?.text = phoneNumberToFormattedString(phoneNumber: emergencyArray[indexPath.row].1)
            cell.detailTextLabel?.textColor = UIColor.lightGray
            
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "EMERGENCY CONTACTS"
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return heightForCalculations * 0.083
        }
        return 0.0
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        print("IN viewForHeaderSction")
        if section == 1 {
        let headerFrame = tableView.frame
        let title = UILabel()
        title.frame = CGRect(x: 10, y: 25, width: headerFrame.width, height: 20)
        title.font = UIFont.systemFont(ofSize: 12)
        title.text = self.tableView(tableView, titleForHeaderInSection: section)
        title.textColor = UIColor.lightGray
        title.sizeToFit()
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: headerFrame.width, height: headerFrame.height))
        headerView.addSubview(title)
        return headerView
        }
        return UIView()
    }
    
    /*func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if section == 1 {
            let title = UILabel()
            let header = view as! UITableViewHeaderFooterView
            title.frame = CGRect(x: header.frame.minX, y: header.frame.maxY - 5, width: 20, height: 10)
            title.font = UIFont.systemFont(ofSize: 12)
            title.text = "EMERGENCY CONTACTS"
            title.sizeToFit()
            title.textColor = UIColor.lightGray
            header.textLabel?.font = title.font
            header.textLabel?.textColor = title.textColor
            header.textLabel?.text = title.text
            header.textLabel?.frame = title.frame
        }
    } */
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return heightForCalculations * 0.36
        }
        else {
            return heightForCalculations * 0.126
        }
    }
    
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //eventually fetch from cell
        let phoneNumber = emergencyArray[indexPath.row].1
        if let phoneCallNumber = URL(string: "tel://\(phoneNumber)") {
            if (UIApplication.shared.canOpenURL(phoneCallNumber)) {
                
                if #available(iOS 10.0, *) {
                UIApplication.shared.open(phoneCallNumber, options: [:], completionHandler: nil)
                }
                else {
                    UIApplication.shared.openURL(phoneCallNumber)
                }
            }
        }
    }
}
