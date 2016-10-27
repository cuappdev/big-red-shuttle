//
//  Time.swift
//  big-red-shuttle
//
//  Created by Monica Ong on 10/26/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

//Note: stores time using 24-hour system
import Foundation

//Sort by descending times
public func timeCompare(_ t1: Time, _ t2:Time) -> Bool{
    if t1.hour > t2.hour{
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

public class Time: NSObject {
    public var hour: Int //in 24 hours
    public var minute: Int
    
    public init(hour: Int, minute: Int){
        self.hour = hour
        self.minute = minute
    }
    


}
