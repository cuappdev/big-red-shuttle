//
//  EmergencyViewController.swift
//  big-red-shuttle
//
//  Created by Austin Astorga on 10/26/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import UIKit

class EmergencyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView: UITableView
    let emergencyArray = [("Cornell Police", 0123456789), ("BlueLight Escort", 0987654321)] //add more later

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tableViewFrame = CGRect(x: <#T##Double#>, y: <#T##Double#>, width: <#T##Double#>, height: <#T##Double#>)
        tableView = UITableView(frame: <#T##CGRect#>, style: .plain)
        
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(self.tableView)
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: tableview functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 //number of cells in tableView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "emergencyCell")
        cell.textLabel.text = emergencyArray[indexPath].0
        cell.detailTextLabel?.text = emergencyArray[indexPath].1
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        //eventually fetch from cell
        let phoneNumber = emergencyArray[indexPath].1
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
