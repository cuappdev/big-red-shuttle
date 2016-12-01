//
//  Time.swift
//  big-red-shuttle
//
//  Created by Monica Ong on 10/26/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

//Note: stores time using 24-hour system
import Foundation

public class Time: NSObject {
    public var hour: Int // in 24 hours
    public var minute: Int
    public var day: Int
    
    public var shortDescription: String {
        let civilianHour = hour == 0 ? 12 : hour % 12
        let displayMinute = minute < 10 ? "0\(minute)" : "\(minute)"
        let ampm = hour < 12 ? "am" : "pm"
        
        return "\(civilianHour):\(displayMinute) \(ampm)"
    }
    
    override public var description: String {
        let dayString = Days.fromNumber(num: day == 1 ? 7 : day - 1)!.rawValue
        return "\(shortDescription) on \(dayString) night"
    }
    
    public convenience init(time: String, technicallyNightBefore: Int) {
        let (hour, minute) = getTime(time: time)
        self.init(hour: hour, minute: minute, technicallyNightBefore: technicallyNightBefore)
    }
    
    public init(hour: Int, minute: Int, day: Int){
        self.hour = hour
        self.minute = minute
        self.day = day
    }
    
    public init(hour: Int, minute: Int, technicallyNightBefore: Int){
        self.hour = hour
        self.minute = minute
        self.day = technicallyNightBefore + 1 > 7 ? 1 : technicallyNightBefore + 1
    }
    
    public func isEarlier(than time: Time) -> Bool {
        if day < time.day || (day == 7 && time.day == 1) {
            return true
        } else if day > time.day {
            return false
        } else if hour > time.hour {
            return false
        } else if hour < time.hour {
            return true
        } else{
            return minute <= time.minute
        }
    }
    
    public func atMost24HoursLater(than time: Time) -> Bool {
        return (day == time.day && hour >= time.hour) || (day > time.day && hour <= time.hour)
    }
    
    public func sameDay(asTime time: Time) -> Bool {
        return day == time.day
    }
    
    public func dayBefore(time: Time) -> Bool {
        return time.day == 1 ? day == 7 : time.day - 1 == day
    }
}
