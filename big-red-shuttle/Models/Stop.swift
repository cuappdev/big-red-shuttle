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
    
    public func allArrivalsToday() -> [String] {
        let components = Calendar.current.dateComponents([.hour, .minute, .weekday], from: Date())
        let currentDay =  Days.fromNumber(num: components.weekday!)!.rawValue

        return times.filter { $0.description.range(of: currentDay) != nil }.map { time in time.shortDescription }
    }
    
    public func nextArrivalsToday() -> [String] {
        let components = Calendar.current.dateComponents([.hour, .minute, .weekday], from: Date())
        guard let currentHour = components.hour, let currentMinute = components.minute, let currentDay = components.weekday else { return [] }
        let currentTime = Time(hour: currentHour, minute: currentMinute, day: currentDay)
        
        return times.filter { time in currentTime.sameDay(asTime: time) && currentTime.isEarlier(than: time) }.map { time in time.shortDescription }
    }
    
    public func nextArrival() -> String {
        let components = Calendar.current.dateComponents([.hour, .minute, .weekday], from: Date())
        guard let currentHour = components.hour, let currentMinute = components.minute, let currentDay = components.weekday else { return "––" }
        let currentTime = Time(hour: currentHour, minute: currentMinute, day: currentDay)
        for time in times {
            if currentTime.isEarlier(than: time) {
                return currentTime.sameDay(asTime: time) ? time.shortDescription : time.description
            }
        }
        return times.first?.description ?? "--"
    }
}

func == (lhs: Stop, rhs: Stop) -> Bool {
    return lhs.name == rhs.name
}
