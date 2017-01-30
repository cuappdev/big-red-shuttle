//
//  Stop.swift
//  big-red-shuttle
//
//  Created by Monica Ong on 10/16/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps

// Sunday = "Sunday", ... Saturday = "Saturday"
public enum Days: String {
    case Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
    
    var number: Int {
        switch self {
        case .Sunday:
            return 1
        case .Monday:
            return 2
        case .Tuesday:
            return 3
        case .Wednesday:
            return 4
        case .Thursday:
            return 5
        case .Friday:
            return 6
        case .Saturday:
            return 7
        }
    }
    
    static func fromNumber(num: Int) -> Days? {
        switch num {
        case 1:
            return .Sunday
        case 2:
            return .Monday
        case 3:
            return .Tuesday
        case 4:
            return .Wednesday
        case 5:
            return .Thursday
        case 6:
            return .Friday
        case 7:
            return .Saturday
        default:
            return nil
        }
    }
}

public class Stop: NSObject {
    
    public var name: String
    public var lat: Float
    public var long: Float
    public var days: [Days]
    public var times: [Time]
    
    public init(name: String, lat: Float, long: Float, days: [Days], times: [Time]) {
        self.name = name
        self.lat = lat
        self.long = long
        self.days = days
        self.times = times
    }
    
    public func getLocation() -> (lat: Float,long: Float) {
        return (lat: lat, long: long)
    }
    
    public func getCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(long))
    }
    
    public func allArrivalTimesInDay() -> [String] {
        var allTimes: [String] = []
        
        for time in times {
            let timeString = time.shortDescription
            if !allTimes.contains(timeString) {
                allTimes.append(timeString)
            }
        }
        
        return allTimes
    }
    
    public func nextArrivalInDay() -> String {
        if let currentTime = getCurrentTime(), nextArrivalToday() != "--" {
            let allArrivalsInDay = allArrivalTimesInDay()
            
            for arrival in allArrivalsInDay {
                let arrivalTimeTuple = getTime(time: arrival)
                let arrivalTime = Time(day: currentTime.day, hour: arrivalTimeTuple.0, minute: arrivalTimeTuple.1)
                
                if currentTime.isEarlier(than: arrivalTime) { return arrival }
            }
        }
        
        return "--"
    }
    
    public func nextArrivalsToday() -> [String] {
        guard let currentTime = getCurrentTime() else { return [] }
        
        return times.filter { time in currentTime.sameDay(asTime: time) && currentTime.isEarlier(than: time) }.map { time in time.shortDescription }
    }
    
    public func allArrivalsTomorrow() -> [String] {
        guard let currentTime = getCurrentTime() else { return [] }
       
        return times.filter { time in currentTime.dayBefore(time: time) }.map { time in time.shortDescription }
    }
    
    public func nextArrivalToday() -> String {
        return nextArrivalsToday().first ?? "--"
    }
    
    public func nextArrival(description: Bool) -> String {
        if let currentTime = getCurrentTime() {
            for time in times {
                if currentTime.isEarlier(than: time) {
                    return description ? time.description : time.shortDescription
                }
            }
        }

        return times.first?.description ?? "--"
    }
}

func == (lhs: Stop, rhs: Stop) -> Bool {
    return lhs.name == rhs.name
}
