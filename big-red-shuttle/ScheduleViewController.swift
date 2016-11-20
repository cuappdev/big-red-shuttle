//
//  ScheduleViewController.swift
//  
//
//  Created by Monica Ong on 10/30/16.
//
//

import UIKit

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ScheduleBarDelegate, UIScrollViewDelegate {
    
    var table: UITableView!
    var stops: [String]!
    var times: [String]!
    var looptimes: [String]!
    var scheduleBar: ScheduleBar!
    
    let identifier: String = "Schedule Cell"
    let loopStop: String = "Jessup & Program House Drive"
    let cellHeight: CGFloat = 55.0
    let barHeight: CGFloat = 55.0
    
    var scrolling: Bool = false
    var initialTableRow: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Data
        stops = ["Jessup & Program House Drive", "Kelvin & Wyckoff", "Stewart & University", "Baker Flagpole", "Schwartz Center", "Dryden & Eddy", "Stewart & University 2", "Thurston & Cradit Farm", "Jessup & Program House Drive", "Kelvin & Wyckoff", "Stewart & University", "Baker Flagpole", "Schwartz Center", "Dryden & Eddy", "Stewart & University 2", "Thurston & Cradit Farm", "Jessup & Program House Drive", "Kelvin & Wyckoff", "Stewart & University", "Baker Flagpole", "Schwartz Center", "Dryden & Eddy", "Stewart & University 2", "Thurston & Cradit Farm", "Jessup & Program House Drive", "Kelvin & Wyckoff", "Stewart & University", "Baker Flagpole", "Schwartz Center", "Dryden & Eddy", "Stewart & University 2", "Thurston & Cradit Farm", "Jessup & Program House Drive", "Kelvin & Wyckoff", "Stewart & University", "Baker Flagpole", "Schwartz Center", "Dryden & Eddy", "Stewart & University 2", "Thurston & Cradit Farm", "Jessup & Program House Drive", "Kelvin & Wyckoff", "Stewart & University", "Baker Flagpole", "Schwartz Center", "Dryden & Eddy", "Stewart & University 2", "Thurston & Cradit Farm", "Jessup & Program House Drive", "Kelvin & Wyckoff", "Stewart & University", "Baker Flagpole", "Schwartz Center", "Dryden & Eddy", "Stewart & University 2", "Thurston & Cradit Farm"]
        times = ["12:00 am", "12:02 am", "12:04 am", "12:06 am", "12:07 am", "12:08 am", "12:10 am", "12:12 am", "12:14 am", "12:16 am", "12:18 am", "12:20 am", "12:22 am", "12:24 am", "12:26 am", "12:28 am", "12:30 am", "12:32 am", "12:34 am", "12:36 am", "12:38 am", "12:40 am", "12:42 am", "12:44 am", "12:46 am", "12:48 am", "12:50 am", "12:52 am", "12:54 am", "12:56 am","12:58 am", "1:00 am", "1:02 am", "1:04 am", "1:06 am", "1:08 am", "1:10 am", "1:12 am", "1:14 am", "1:16 am", "1:18 am", "1:20 am", "1:22 am", "1:24 am", "1:26 am", "1:28 am", "1:30 am", "1:32 am", "1:34 am", "1:36 am", "1:38 am", "1:40 am", "1:42 am", "1:44 am", "1:46 am", "1:48 am"]
        looptimes = ["12:00 am", "12:14 am", "12:30 am", "12:46 am", "1:02 am", "1:18 am", "1:34 am"]
        
        let selectedTime = "12:30 am"
        let selectedIndex = looptimes.index(of: selectedTime)!
        initialTableRow = times.index(of: selectedTime)!
        
        //Bar
        scheduleBar = ScheduleBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: barHeight))
        scheduleBar.setUp(buttonsData: looptimes, selected: selectedIndex)
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
        let indexPath = IndexPath(row: initialTableRow, section: 0)
        table.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    // MARK: - Scroll view delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        if !scrolling{
            let scheduleCell = table.visibleCells[0] as! ScheduleTableViewCell
            let time = scheduleCell.time.text!
            if(looptimes.contains(time)){
                let i = looptimes.index(of: time)
                scheduleBar.select(button: scheduleBar.buttons[i!], animation: true)
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView){
        scrolling = false
    }
    // MARK: - Schedule Bar delegate
    
    //Scrolls tableview to cell with time corresponding to the schedubar's button's time    
    func scrollToCell(button: UIButton) {
        scrolling = true
        let row = times.index(of: (button.titleLabel?.text)!)
        let indexPath = IndexPath(row: row!, section: 0)
        print(indexPath)
        table.scrollToRow(at: indexPath, at: .top, animated: true)
        //So autoscrolling of schedulebar doesn't happen at the same time
        let rect = table.visibleCells[0].frame
        table.scrollRectToVisible(rect, animated: true)
    }
    
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
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
