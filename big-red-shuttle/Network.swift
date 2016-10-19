//
//  Network.swift
//  big-red-shuttle
//
//  Created by Austin Astorga on 10/19/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import Foundation
import SwiftyJSON


public func getStops() ->  [Stop] {
    let stopJsonString = "https://raw.githubusercontent.com/cuappdev/big-red-shuttle-stack/master/big-red-shuttle.json"
    var stops = [Stop]()
    if let url = URL(string: stopJsonString) {
        if let data = try? Data(contentsOf: url) {
            let json = JSON(data: data)
            for stop in json["stops"].arrayValue {
                var dayArray = [Days]()
                let name = stop["name"].stringValue
                let lat = stop["lat"].floatValue
                let long = stop["long"].floatValue
                let days = stop["days"].arrayObject!
                
                for day in days {
                    
                    dayArray.append(Days(rawValue: day as! String)!)
                }
                
                let times = stop["times"].arrayObject!
                stops.append(Stop(name: name, lat: lat, long: long, days: dayArray, times: times as! [String]))
  
            }
        }
    }
    return stops
}
