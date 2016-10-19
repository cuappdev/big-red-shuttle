//
//  Network.swift
//  big-red-shuttle
//
//  Created by Austin Astorga on 10/19/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import Foundation
import SwiftyJSON


public func getStops() ->  [String] {
    let stopJsonString = "https://raw.githubusercontent.com/cuappdev/big-red-shuttle-stack/master/big-red-shuttle.json"
    var stops = [Stop]()
    if let url = URL(string: stopJsonString) {
        if let data = try? Data(contentsOf: url) {
            let json = JSON(data: data)
            print(json)
            for stop in json["stops"].arrayValue {
                let name = stop[0]
                print("name is: \(name)")
            }
            
            
            
            
            }
    }
return ["Test"]
}
