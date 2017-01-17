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
    let noBusLabelHeight: CGFloat = 60
    let barHeight: CGFloat = 58
    let redLinePercOffset: CGFloat = 0.23
    let separatorHeight: CGFloat = 1.2
    
    var noBusLabel: UILabel!
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
        
        if loopStop?.nextArrivalToday() == "--" {
            noBusLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: noBusLabelHeight))
            noBusLabel.numberOfLines = 2
            let nextArrivalText = stops.first?.nextArrival() ?? "--"
            noBusLabel.text = "The shuttle will start running again\nat \(nextArrivalText)"
            noBusLabel.font = UIFont(name: "SFUIDisplay-Medium", size: 14.0)
            noBusLabel.textColor = .brsgrey
            noBusLabel.backgroundColor = .brslightgrey
            noBusLabel.textAlignment = .center
            
            let separator = UIView(frame: CGRect(x: 0, y: noBusLabel.frame.height - separatorHeight, width: view.frame.width, height: separatorHeight))
            separator.backgroundColor = .brsgray
            noBusLabel.addSubview(separator)
            
            view.addSubview(noBusLabel)
            
            scheduleBar = ScheduleBar(frame: CGRect(x: 0, y: noBusLabel.frame.height, width: view.frame.width, height: barHeight))
        } else {
            scheduleBar = ScheduleBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: barHeight))
        }
        
        // Schedule Bar
        scheduleBar.sbDelegate = self
        
        if let loopStop = loopStop {
            scheduleBar.setUp(buttonsData: loopStop.allArrivalTimesInDay(), selected: 0)
        }
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let loopStop = loopStop {
            let nextArrival = loopStop.nextArrivalInDay()
            
            for button in scheduleBar.timeButtons {
                if button.titleLabel?.text == nextArrival {
                    scheduleBar.scrollToButton(button: button)
                    scrollToCell(button: button)
                }
            }
        }
    }
    
    // MARK: - Schedule Bar Delegate Methods
    
    // Scroll tableview to cell with correct time button
    func scrollToCell(button: UIButton) {
        scheduleBar.isAnimating = true
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { self.scheduleBar.isAnimating = false }
        
        tableView.beginUpdates()
        
        let indexPath = IndexPath(row: stops.count * button.tag, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        
        tableView.endUpdates()
        
        CATransaction.commit()
    }
    
    // MARK: - TableView Datasource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numLoops = loopStop?.allArrivalTimesInDay().count ?? 0
        
        return stops.count * numLoops
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
        
        if let loopStop = loopStop {
            cell?.configStop(loop: stop.name == loopStop.name)
        }
        
        cell?.timeLabel.text = stop.allArrivalTimesInDay()[timeIndex]
        cell?.stopLabel.text = stop.name
        cell?.timeLabel.sizeToFit()
        cell?.stopLabel.sizeToFit()
        
        return cell!
    }
    
    // MARK: - TableView ScrollView Delegate Methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollViewHeight = scrollView.frame.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y
        
        if !scheduleBar.isAnimating {
            let index = Int(tableView.contentOffset.y / (cellHeight * CGFloat(stops.count)))
            let buttons = scheduleBar.timeButtons as [UIButton]
            let button = (scrollViewHeight + scrollOffset >= scrollContentSizeHeight) ? buttons.last : buttons[index]
            
            scheduleBar.scrollToButton(button: button!)
        }
    }

}
