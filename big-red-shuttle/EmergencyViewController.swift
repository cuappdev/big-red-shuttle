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

    let emergencyArray = [(service: "Call Cornell University Police",number: "6072551111"), (service:"Call Emergency Services",number: "911"), (service:"Call Blue Light Escorts",number: "6072557373"), (service:"Call Gannett Health Services",number: "6072555155")]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Emergency"

        let tableViewFrame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - (tabBarController?.tabBar.frame.height)!)
        
        tableView = UITableView(frame: tableViewFrame, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .brslightgrey
        tableView.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
        
        view.addSubview(tableView)
    }
    
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    /*phoneNumberToFormattedString takes in number and converts it to a (XXX) YYY-YYYY string */
    func phoneNumberToFormattedString(phoneNumber: String) -> String {
        var stringOfPhoneNumber = String(describing: phoneNumber)
        if stringOfPhoneNumber.characters.count == 10 {
            let startIndex = stringOfPhoneNumber.startIndex
            stringOfPhoneNumber.insert("(", at: startIndex)
            stringOfPhoneNumber.insert(")", at: stringOfPhoneNumber.index(startIndex, offsetBy: 4))
            stringOfPhoneNumber.insert(" ", at: stringOfPhoneNumber.index(startIndex, offsetBy: 5))
            stringOfPhoneNumber.insert("-", at: stringOfPhoneNumber.index(startIndex, offsetBy: 9))
        }
        return stringOfPhoneNumber
    }

    
    //MARK: tableview functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? emergencyArray.count : 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell!
        if indexPath.section == 0 {
            cell = UITableViewCell(style: .default, reuseIdentifier: "header")
            
            let imageView = UIImageView(image: UIImage(named: "eye"))
            imageView.frame = CGRect(x: 0, y: 0, width: 46, height: 32)
            imageView.center = CGPoint(x: view.frame.midX, y: 40)
            imageView.tintColor = .brsred

            let safetyLabel = UILabel()
            safetyLabel.text = "Safety is our mission"
            safetyLabel.font = .boldSystemFont(ofSize: 18)
            safetyLabel.textColor = .brsblack
            safetyLabel.sizeToFit()
            safetyLabel.center = CGPoint(x: view.frame.midX, y: 85)
        
            let safetyLabelDetail = UILabel(frame: CGRect(x: safetyLabel.frame.minX, y: 130, width: safetyLabel.frame.maxX + 30, height: 10))
            safetyLabelDetail.textAlignment = .center
            safetyLabelDetail.text = "If there is an emergency, please call the appropriate service."
            safetyLabelDetail.font = UIFont.systemFont(ofSize: 16)
            safetyLabelDetail.textColor = .brsgreyedout
            safetyLabelDetail.numberOfLines = 2
            safetyLabelDetail.sizeToFit()
            safetyLabelDetail.center = CGPoint(x: view.frame.midX, y: 130)
            cell.addSubview(imageView)
            cell.addSubview(safetyLabel)
            cell.addSubview(safetyLabelDetail)
            cell.isUserInteractionEnabled = false

        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "emergencyCell")
            cell.textLabel?.text = emergencyArray[indexPath.row].service
            cell.detailTextLabel?.text = phoneNumberToFormattedString(phoneNumber: emergencyArray[indexPath.row].number)
            cell.detailTextLabel?.textColor = .brsgreyedout
            cell.textLabel?.textColor = .brsblack
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "EMERGENCY CONTACTS" : nil
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 1.0 : 30.0
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 170.0 : 80.0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let phoneNumber = emergencyArray[indexPath.row].number
        let serviceName = emergencyArray[indexPath.row].service
        let parsedName = serviceName.substring(from: serviceName.index(serviceName.startIndex, offsetBy: 4))
        let alertController = UIAlertController(title: parsedName, message: "" , preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Call", style: .default, handler: { result in
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
        present(alertController, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
