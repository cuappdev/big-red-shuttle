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
    let emergencyArray = [("Call Cornell Univeristy Police", 6072551111), ("Call Emergency Services", 911), ("Call Blue Light Escorts", 6072557373), ("Call Gannett Health Services", 6072555155)] //add more later
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "Emergency"
        let tableViewFrame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - (tabBarController?.tabBar.frame.height)!)
        
        self.tableView = UITableView(frame: tableViewFrame, style: .grouped)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0)
        tableView.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
        
        self.view.addSubview(self.tableView)
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
            stringOfPhoneNumber.insert(")", at: stringOfPhoneNumber.index(startIndex, offsetBy: 4))
            stringOfPhoneNumber.insert(" ", at: stringOfPhoneNumber.index(startIndex, offsetBy: 5))
            stringOfPhoneNumber.insert("-", at: stringOfPhoneNumber.index(startIndex, offsetBy: 9))
            
            return stringOfPhoneNumber
        } else{
            
            return stringOfPhoneNumber
        }
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
        if indexPath.section == 0 {
            let cell = UITableViewCell()

            //imageView
            let imageView = UIImageView()
            imageView.image = UIImage(named: "eye")
            //117 width 63 height
            imageView.frame = CGRect(x: 0, y: 0, width: 46, height: 32)
            imageView.center = CGPoint(x: view.frame.midX, y: 40)
            imageView.tintColor = UIColor(red:0.83, green:0.29, blue:0.24, alpha:1.0)
            //Safety Label
            let safetyLabel = UILabel()
            safetyLabel.text = "Safety is our mission"

            safetyLabel.font = UIFont.boldSystemFont(ofSize: 18)
            safetyLabel.sizeToFit()
            safetyLabel.center = CGPoint(x: view.frame.midX, y: 85)
            
            //Safety Detail Label
            let safetyLabelDetail = UILabel(frame: CGRect(x: safetyLabel.frame.minX, y: 130, width: safetyLabel.frame.maxX + 30, height: 10))
            
            safetyLabelDetail.textAlignment = .center
            safetyLabelDetail.text = "If there is an emergency, please call the appropriate service."

            safetyLabelDetail.font = UIFont.systemFont(ofSize: 16)
            safetyLabelDetail.textColor = .lightGray
            safetyLabelDetail.numberOfLines = 2
            safetyLabelDetail.sizeToFit()

            safetyLabelDetail.center = CGPoint(x: view.frame.midX, y: 130)

            cell.addSubview(imageView)
            cell.addSubview(safetyLabel)
            cell.addSubview(safetyLabelDetail)
            
            cell.isUserInteractionEnabled = false
            
            return cell
        } else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "emergencyCell")
            cell.textLabel?.text = emergencyArray[indexPath.row].0
            cell.detailTextLabel?.text = phoneNumberToFormattedString(phoneNumber: emergencyArray[indexPath.row].1)

            cell.detailTextLabel?.textColor = .lightGray
            
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "EMERGENCY CONTACTS"
        }
        
        return nil
    }
    
    

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1.0
        }
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 170.0
        }
        else {
            return 80.0
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let phoneNumber = emergencyArray[indexPath.row].1
        let serviceName = emergencyArray[indexPath.row].0
        let parsedName = serviceName.substring(from: serviceName.index(serviceName.startIndex, offsetBy: 4))
        
        
        
        let alertController = UIAlertController(title: parsedName, message: "" , preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (result: UIAlertAction) -> Void in
            
        })
        let okAction = UIAlertAction(title: "Call", style: .default, handler: { (result: UIAlertAction) -> Void in
            
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
            
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
