//
//  ScheduleViewController.swift
//  
//
//  Created by Monica Ong on 10/30/16.
//
//

import UIKit

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ScheduleBarDelegate {
    
    let identifier: String = "Schedule Cell"
    let cellHeight: CGFloat = 42
    let barHeight: CGFloat = 58
    let redLinePercOffset: CGFloat = 0.23
    
    var scheduleBar: ScheduleBar!
    var tableView: UITableView!
    var stops: [Stop] = []
    var loopStop: Stop?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Schedule"
        view.backgroundColor = .white
        
        stops = getStops()
        loopStop = stops.first
        
        // Schedule Bar
        scheduleBar = ScheduleBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: barHeight))
        scheduleBar.setUp(buttonsData: loopStop!.allArrivalsToday(), selected: 0)
        scheduleBar.sbDelegate = self
        view.addSubview(scheduleBar)
        
        // Table View
        tableView = UITableView(frame: CGRect(x: 0, y: scheduleBar.frame.maxY, width: view.frame.width, height: view.frame.height - UIApplication.shared.statusBarFrame.height - (navigationController?.navigationBar.frame.height)! - scheduleBar.frame.height - (navigationController?.tabBarController?.tabBar.frame.height)!))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = cellHeight
        view.addSubview(tableView)
        
        // Red Route Line
        let line = UIView(frame: CGRect(x: view.frame.width * redLinePercOffset, y: 0, width: 3.0, height: view.frame.height))
        line.backgroundColor = .brsred
        view.addSubview(line)
        view.sendSubview(toBack: line)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.register(ScheduleTableViewCell.classForCoder(), forCellReuseIdentifier: identifier)
    }
    
    // MARK: - Schedule Bar Delegate Methods
    
    // Scroll tableview to cell with correct time button
    func scrollToCell(button: UIButton) {
        let indexPath = IndexPath(row: stops.count * button.tag, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    // MARK: - TableView Datasource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stops.count * loopStop!.allArrivalsToday().count
    }
    
    // MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ScheduleTableViewCell
        
        if cell == nil {
            cell = ScheduleTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        }
        
        let stopIndex = indexPath.row % stops.count
        let timeIndex = indexPath.row / stops.count
        let stop = stops[stopIndex]
        
        cell?.configStop(loop: stop.name == loopStop?.name)
        cell?.timeLabel.text = stop.allArrivalsToday()[timeIndex]
        cell?.stopLabel.text = stop.name
        cell?.timeLabel.sizeToFit()
        cell?.stopLabel.sizeToFit()
        
        return cell!
    }
    
}
