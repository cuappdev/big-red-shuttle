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
    public var hour: Int //in 24 hours
    public var minute: Int
    public var day: Int
    
    public var shortDescription: String {
        let ampm = hour < 12 ? "am" : "pm"
        var civilianHour = hour > 12 ? hour - 12 : hour
        civilianHour  = hour == 0 ? 12 : civilianHour
        let displayMinute = minute < 10 ? "0\(minute)" : "\(minute)"
        
        return "\(civilianHour):\(displayMinute) \(ampm)"
    }
    
    override public var description: String {
        let dayString = Days.fromNumber(num: day-1)!.rawValue
        return "\(shortDescription) on \(dayString) night"
    }
    
    public convenience init(time: String, day: Int) {
        let (hour, minute) = getTime(time: time)
        self.init(hour: hour, minute: minute, day: day)
    }
    
    public init(hour: Int, minute: Int, day: Int){
        self.hour = hour
        self.minute = minute
        self.day = day + 1
        if self.day > 7 {
            self.day = 1
        }
    }
    
    public func isEarlier(than time: Time) -> Bool {
        let t1 = self
        let t2 = time
        if t1.day > t2.day || (t1.day == 1 && t2.day == 7)  {
            return false
        } else if t1.day < t2.day {
            return true
        } else if t1.hour > t2.hour{
            return false
        } else if t1.hour < t2.hour {
            return true
        } else{
            if t1.minute > t2.minute{
                return false
            }else{
                return true
            }
        }
    }
}
