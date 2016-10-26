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
    
    public init(hour: Int, minute: Int){
        self.hour = hour
        self.minute = minute
    }
    
    /* Creates time from JSON string
     * Time string must have format:
     * H:mm a
    */
    public init(time: String){
        var hourArr = time.components(separatedBy: ":") //["h","mm a"]
        let minArr = hourArr[1].components(separatedBy: " ") //["mm","a"]
        let timeArr = [hourArr[0]] + minArr //["h","mm","a"]
        
        self.minute = Int(timeArr[1])!
        
        let hour12 = Int(hourArr[0])!
        
        let aa = timeArr[2].lowercased()
        if(aa=="am" && hour12 == 12){ //12:xx am = 0:xx
            self.hour = 0
        }else if(aa=="pm" && hour12 != 12){ //12:xx pm = 12:xx
            self.hour = hour + 12 //h:xx pm = (h+12):xx
        }
    }
}
