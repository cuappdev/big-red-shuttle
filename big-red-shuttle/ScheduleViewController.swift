//
//  ScheduleViewController.swift
//  
//
//  Created by Monica Ong on 10/30/16.
//
//

import UIKit

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ScheduleBarDelegate {
    
    private var table: UITableView!
    private var stops: [String]!
    private var times: [String]!
    private var scheduleBar: ScheduleBar!
    
    private let identifier: String = "Schedule Cell"
    private let cellHeight: CGFloat = 55
    private let barHeight: CGFloat = 55
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Data
        //Q: How are we differentiating bt Stewart and University & Stewart and University- up to Thurston?
        stops = ["Jessup & Program House Drive", "Kelvin & Wyckoff", "Stewart & University", "Baker Flagpole", "Schwartz Center", "Dryden & Eddy", "Stewart & University 2", "Thurston & Cradit Farm", "Jessup & Program House Drive", "Kelvin & Wyckoff", "Stewart & University", "Baker Flagpole", "Schwartz Center", "Dryden & Eddy", "Stewart & University 2", "Thurston & Cradit Farm"]
        times = ["12:00 am", "12:02 am", "12:04 am", "12:06 am", "12:07 am", "12:08 am", "12:10 am", "12:12 am", "12:14 am", "12:16 am", "12:18 am", "12:20 am", "12:22 am", "12:24 am", "12:26 am", "12:28 am"]
        let looptimes = ["12:00 am", "12:07 am", "12:12 am", "12:16 am", "12:18 am", "12:28 am"]
        
        //Bar
        scheduleBar = ScheduleBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: barHeight))
        scheduleBar.setUp(buttonsData: looptimes, selected: 2)
        scheduleBar.delegateSB = self
        self.view.addSubview(scheduleBar)
        
        //Table
        table = UITableView(frame: CGRect(x: 0, y: scheduleBar.frame.maxY, width: view.bounds.width, height: view.bounds.height - (navigationController?.navigationBar.bounds.height)! - (navigationController?.tabBarController?.tabBar.bounds.height)! - scheduleBar.bounds.height))
        table.separatorStyle = UITableViewCellSeparatorStyle.none
        table.delegate = self
        table.dataSource = self
        self.view.addSubview(table)
        
        //Nav
        self.navigationController?.navigationBar.topItem?.title = "Schedule"
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        table.register(ScheduleTableViewCell.classForCoder(), forCellReuseIdentifier: identifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Schedule Bar delegate
    
    func selectCell(button: UIButton) {
        let indexPath = IndexPath(row: button.tag, section: 0)
        table.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return times.count
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ScheduleTableViewCell
        if cell == nil{
            cell = ScheduleTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        }
        
        var loopBeginning: Bool
        if stops[indexPath.row] == "Jessup & Program House Drive"{
            loopBeginning = true
        }else{
            loopBeginning = false
        }
        cell?.configLoopBegin(loop: loopBeginning)
        cell?.time.text = times[indexPath.row]
        cell?.stop.text = stops[indexPath.row]
        cell?.time.sizeToFit()
        cell?.stop.sizeToFit()
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
