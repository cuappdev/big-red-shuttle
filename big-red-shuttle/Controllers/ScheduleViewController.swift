//
//  ScheduleViewController.swift
//  
//
//  Created by Monica Ong on 10/30/16.
//
//

import UIKit

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ScheduleBarDelegate {
    
    var table: UITableView!
    var stops: [String]!
    var times: [String]!
    var looptimes: [String]!
    var scheduleBar: ScheduleBar!
    
    let identifier: String = "Schedule Cell"
    let loopStop: String = "Jessup & Program House Drive"
    let cellHeight: CGFloat = 42
    let barHeight: CGFloat = 58
    let redLinePercOffset: CGFloat = 0.23
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Schedule"
        view.backgroundColor = .white
        
        //Data
        stops = ["Jessup & Program House Drive", "Kelvin & Wyckoff", "Stewart & University", "Baker Flagpole", "Schwartz Center", "Dryden & Eddy", "Stewart & University 2", "Thurston & Cradit Farm", "Jessup & Program House Drive", "Kelvin & Wyckoff", "Stewart & University", "Baker Flagpole", "Schwartz Center", "Dryden & Eddy", "Stewart & University 2", "Thurston & Cradit Farm", "Jessup & Program House Drive", "Kelvin & Wyckoff", "Stewart & University", "Baker Flagpole", "Schwartz Center", "Dryden & Eddy", "Stewart & University 2", "Thurston & Cradit Farm", "Jessup & Program House Drive", "Kelvin & Wyckoff", "Stewart & University", "Baker Flagpole", "Schwartz Center", "Dryden & Eddy", "Stewart & University 2", "Thurston & Cradit Farm", "Jessup & Program House Drive", "Kelvin & Wyckoff", "Stewart & University", "Baker Flagpole", "Schwartz Center", "Dryden & Eddy", "Stewart & University 2", "Thurston & Cradit Farm"]
        times = ["12:00 am", "12:02 am", "12:04 am", "12:06 am", "12:07 am", "12:08 am", "12:10 am", "12:12 am", "12:14 am", "12:16 am", "12:18 am", "12:20 am", "12:22 am", "12:24 am", "12:26 am", "12:28 am", "12:30 am", "12:32 am", "12:34 am", "12:36 am", "12:38 am", "12:40 am", "12:42 am", "12:44 am", "12:46 am", "12:48 am", "12:50 am", "12:52 am", "12:54 am", "12:56 am","12:58 am", "1:00 am", "1:02 am", "1:04 am", "1:06 am", "1:08 am", "1:10 am", "1:12 am", "1:14 am", "1:16 am"]
        looptimes = ["12:00 am", "12:14 am", "12:30 am", "12:46 am", "1:02 am"]
        
        // Schedule Bar
        scheduleBar = ScheduleBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: barHeight))
        scheduleBar.setUp(buttonsData: looptimes, selected: 0)
        scheduleBar.sbDelegate = self
        view.addSubview(scheduleBar)
        
        // Table View
        table = UITableView(frame: CGRect(x: 0, y: scheduleBar.frame.maxY, width: view.frame.width, height: view.frame.height - UIApplication.shared.statusBarFrame.height - (navigationController?.navigationBar.frame.height)! - scheduleBar.frame.height - (navigationController?.tabBarController?.tabBar.frame.height)!))
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.rowHeight = cellHeight
        view.addSubview(table)
        
        // Red Route Line
        let line = UIView(frame: CGRect(x: view.frame.width * redLinePercOffset, y: 0, width: 3.0, height: view.frame.height))
        line.backgroundColor = .brsred
        view.addSubview(line)
        view.sendSubview(toBack: line)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        table.register(ScheduleTableViewCell.classForCoder(), forCellReuseIdentifier: identifier)
    }
    
    // MARK: - Schedule Bar Delegate Methods
    
    // Scroll tableview to cell with correct time button
    func scrollToCell(button: UIButton) {
        let row = times.index(of: (button.titleLabel?.text)!)
        let indexPath = IndexPath(row: row!, section: 0)
        table.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    // MARK: - TableView Datasource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return times.count
    }
    
    // MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ScheduleTableViewCell
        
        if cell == nil {
            cell = ScheduleTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        }
        
        cell?.configStop(loop: stops[indexPath.row] == loopStop)
        cell?.timeLabel.text = times[indexPath.row]
        cell?.stopLabel.text = stops[indexPath.row]
        cell?.timeLabel.sizeToFit()
        cell?.stopLabel.sizeToFit()
        
        return cell!
    }
    
}
