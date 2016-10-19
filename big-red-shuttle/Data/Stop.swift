//
//  Stop.swift
//  big-red-shuttle
//
//  Created by Monica Ong on 10/16/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import UIKit

public enum Days: String{
    case Monday = "Monday"
    case Tuesday = "Tuesday"
    case Wednesday = "Wednesday"
    case Thursday = "Thursday"
    case Friday = "Friday"
    case Saturday = "Saturday"
    case Sunday = "Sunday"
}

public class Stop: NSObject {
    
    public var name: String
    public var lat: Float
    public var long: Float
    public var days: [Days]
    public var times: [String]
    
    public init(name: String, lat: Float, long: Float, days: [Days], times: [String]){
        self.name = name
        self.lat = lat
        self.long = long
        self.days = days
        self.times = times
    }
    
    public func getLocation() -> (lat: Float,long: Float){
        return (lat: lat, long: long)
    }
    
}
