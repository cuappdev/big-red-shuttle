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
    let cellHeight: CGFloat = 55.0
    let barHeight: CGFloat = 55.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Data
        stops = ["Jessup & Program House Drive", "Kelvin & Wyckoff", "Stewart & University", "Baker Flagpole", "Schwartz Center", "Dryden & Eddy", "Stewart & University 2", "Thurston & Cradit Farm", "Jessup & Program House Drive", "Kelvin & Wyckoff", "Stewart & University", "Baker Flagpole", "Schwartz Center", "Dryden & Eddy", "Stewart & University 2", "Thurston & Cradit Farm", "Jessup & Program House Drive", "Kelvin & Wyckoff", "Stewart & University", "Baker Flagpole", "Schwartz Center", "Dryden & Eddy", "Stewart & University 2", "Thurston & Cradit Farm", "Jessup & Program House Drive", "Kelvin & Wyckoff", "Stewart & University", "Baker Flagpole", "Schwartz Center", "Dryden & Eddy", "Stewart & University 2", "Thurston & Cradit Farm", "Jessup & Program House Drive", "Kelvin & Wyckoff", "Stewart & University", "Baker Flagpole", "Schwartz Center", "Dryden & Eddy", "Stewart & University 2", "Thurston & Cradit Farm"]
        times = ["12:00 am", "12:02 am", "12:04 am", "12:06 am", "12:07 am", "12:08 am", "12:10 am", "12:12 am", "12:14 am", "12:16 am", "12:18 am", "12:20 am", "12:22 am", "12:24 am", "12:26 am", "12:28 am", "12:30 am", "12:32 am", "12:34 am", "12:36 am", "12:38 am", "12:40 am", "12:42 am", "12:44 am", "12:46 am", "12:48 am", "12:50 am", "12:52 am", "12:54 am", "12:56 am","12:58 am", "1:00 am", "1:02 am", "1:04 am", "1:06 am", "1:08 am", "1:10 am", "1:12 am", "1:14 am", "1:16 am"]
        looptimes = ["12:00 am", "12:14 am", "12:30 am", "12:46 am", "1:02 am"]
        
        //Bar
        scheduleBar = ScheduleBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: barHeight))
        scheduleBar.setUp(buttonsData: looptimes, selected: 0)
        scheduleBar.delegateSB = self
        view.addSubview(scheduleBar)
        
        //Table
        table = UITableView(frame: CGRect(x: 0, y: scheduleBar.frame.maxY, width: view.frame.width, height: view.frame.height - (navigationController?.navigationBar.frame.height)! - (navigationController?.tabBarController?.tabBar.frame.height)! - scheduleBar.frame.height - UIApplication.shared.statusBarFrame.height))
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.rowHeight = cellHeight
        table.delegate = self
        table.dataSource = self
        view.addSubview(table)
        
        //Red line that shows up when scroll past given cells
        let line = UIView(frame: CGRect(x: view.frame.width*0.20, y: 0, width: 3.5, height: view.frame.height))
        line.backgroundColor = .brsred
        view.addSubview(line)
        view.sendSubview(toBack: line)

        
        view.backgroundColor = .white
        //Nav
        navigationController?.navigationBar.topItem?.title = "Schedule"
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        table.register(ScheduleTableViewCell.classForCoder(), forCellReuseIdentifier: identifier)
    }
    
    // MARK: - Schedule Bar delegate
    
    //Scrolls tableview to cell with time corresponding to the schedubar's button's time    
    func scrollToCell(button: UIButton) {
        let row = times.index(of: (button.titleLabel?.text)!)
        let indexPath = IndexPath(row: row!, section: 0)
        table.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return times.count
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ScheduleTableViewCell
        if cell == nil{
            cell = ScheduleTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        }
        
        let loop = (stops[indexPath.row] == loopStop)
        cell?.configStop(loop: loop)
        cell?.time.text = times[indexPath.row]
        cell?.stop.text = stops[indexPath.row]
        cell?.time.sizeToFit()
        cell?.stop.sizeToFit()
        
        return cell!
    }
    
}
