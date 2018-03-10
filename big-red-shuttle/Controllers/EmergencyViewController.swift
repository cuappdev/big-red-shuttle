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
    var emergencyArray: [EmergencyContact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Emergency"
        emergencyArray = getEmergencyContacts()
        
        let tableViewFrame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.frame.height - UIApplication.shared.statusBarFrame.height - (navigationController?.navigationBar.frame.height)! - (navigationController?.tabBarController?.tabBar.frame.height)!)
        tableView = UITableView(frame: tableViewFrame, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .brslightgrey
        tableView.contentInset.top = -1.0
        view.addSubview(tableView)
    }
    
    // Converts a phone number to a formatted (XXX) YYY-YYYY string
    func phoneNumberToFormattedString(phoneNumber: String) -> String {
        var stringOfPhoneNumber = String(describing: phoneNumber)
        
        if stringOfPhoneNumber.count == 10 {
            let startIndex = stringOfPhoneNumber.startIndex
            stringOfPhoneNumber.insert("(", at: startIndex)
            stringOfPhoneNumber.insert(")", at: stringOfPhoneNumber.index(startIndex, offsetBy: 4))
            stringOfPhoneNumber.insert(" ", at: stringOfPhoneNumber.index(startIndex, offsetBy: 5))
            stringOfPhoneNumber.insert("-", at: stringOfPhoneNumber.index(startIndex, offsetBy: 9))
        }
        
        return stringOfPhoneNumber
    }

    
    // MARK: Tableview functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : emergencyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell!
        
        if indexPath.section == 0 {
            cell = UITableViewCell(style: .default, reuseIdentifier: "header")
            
            let safetyImageView = UIImageView(image: UIImage(named: "EyeIcon"))
            safetyImageView.frame.size = CGSize(width: 46, height: 32)
            safetyImageView.center = CGPoint(x: view.frame.midX, y: 60)
            safetyImageView.tintColor = .brsred
            cell.addSubview(safetyImageView)

            let safetyLabel = UILabel()
            safetyLabel.text = "Safety is our mission"
            safetyLabel.font = UIFont(name: "SFUIDisplay-Semibold", size: 16)
            safetyLabel.textColor = .brsblack
            safetyLabel.sizeToFit()
            safetyLabel.center = CGPoint(x: view.frame.midX, y: 106)
            cell.addSubview(safetyLabel)
        
            let safetyDetailLabel = UILabel()
            safetyDetailLabel.bounds.size.width = 250
            safetyDetailLabel.text = "If there is an emergency, please call the appropriate service."
            safetyDetailLabel.font = UIFont(name: "SFUIDisplay-Regular", size: 14)
            safetyDetailLabel.textColor = .brsgrey
            safetyDetailLabel.textAlignment = .center
            safetyDetailLabel.numberOfLines = 2
            safetyDetailLabel.sizeToFit()
            safetyDetailLabel.center = CGPoint(x: view.frame.midX, y: 140)
            cell.addSubview(safetyDetailLabel)
            
            cell.isUserInteractionEnabled = false
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: "emergencyCell")
            
            let serviceLabel = UILabel()
            serviceLabel.text = "Call \(emergencyArray[indexPath.row].service)"
            serviceLabel.font = UIFont(name: "SFUIDisplay-Medium", size: 16)
            serviceLabel.textColor = .brsblack
            serviceLabel.sizeToFit()
            serviceLabel.frame.origin = CGPoint(x: 15, y: 15)
            cell.addSubview(serviceLabel)
            
            let numberLabel = UILabel()
            numberLabel.text = phoneNumberToFormattedString(phoneNumber: emergencyArray[indexPath.row].number)
            numberLabel.font = UIFont(name: "SFUIDisplay-Regular", size: 14)
            numberLabel.textColor = .brsgrey
            numberLabel.sizeToFit()
            numberLabel.frame.origin = CGPoint(x: 15, y: 39)
            cell.addSubview(numberLabel)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "SFUIDisplay-Regular", size: 12)!
        header.textLabel?.textColor = .sectiontitlegrey
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? nil : "EMERGENCY CONTACTS"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 1.0 : 30.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 200.0 : 70.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let serviceName = emergencyArray[indexPath.row].service
        let phoneNumber = emergencyArray[indexPath.row].number
        
        let alertController = UIAlertController(title: serviceName, message: "Are you sure you want to call \(serviceName)?" , preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Call", style: .default, handler: { _ in
            if let phoneCallNumber = URL(string: "tel://\(phoneNumber)") {
                if (UIApplication.shared.canOpenURL(phoneCallNumber)) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(phoneCallNumber, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(phoneCallNumber)
                    }
                }
            }
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}
