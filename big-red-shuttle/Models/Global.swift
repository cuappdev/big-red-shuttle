//
//  Global.swift
//  big-red-shuttle
//
//  Created by Annie Cheng on 11/21/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Constants {
    static let brsStackBaseURL = "https://raw.githubusercontent.com/cuappdev/big-red-shuttle-stack/master/"
}

// MARK: - Information retrieval methods for Big Red Shuttle Stack

// Get BRS stops with name, location, dates, and times
public func getStops() ->  [Stop] {
    let stopJsonURLString = "\(Constants.brsStackBaseURL)brs-stops.json"
    var stops = [Stop]()
    
    if let url = URL(string: stopJsonURLString) {
        if let data = try? Data(contentsOf: url) {
            let json = JSON(data: data)
            for stop in json["stops"].arrayValue {
                var dayArray = [Days]()
                let name = stop["name"].stringValue
                let lat = stop["lat"].floatValue
                let long = stop["long"].floatValue
                let days = stop["days"].arrayObject!
                let timeStrings = stop["times"].arrayObject! as! [String]
                
                var times:[Time] = []
                for day in days {
                    let dayObject = Days(rawValue: day as! String)!
                    dayArray.append(Days(rawValue: day as! String)!)
                    for tStr in timeStrings {
                        times.append(Time(time: tStr, technicallyNightBefore: dayObject.number))
                    }
                }
                stops.append(Stop(name: name, lat: lat, long: long, days: dayArray, times: times))
                
            }
        }
    }
    
    return stops
}

// Get BRS emergency contacts with service and name
public func getEmergencyContacts() -> [EmergencyContact] {
    let emergencyContactsURLString = "\(Constants.brsStackBaseURL)brs-emergency-contacts.json"
    var emergencyContacts = [EmergencyContact]()
    
    if let url = URL(string: emergencyContactsURLString) {
        if let data = try? Data(contentsOf: url) {
            let json = JSON(data: data)
            for contact in json["contacts"].arrayValue {
                let service = contact["service"].stringValue
                let number = contact["number"].stringValue
                
                emergencyContacts.append(EmergencyContact(service: service, number: number))
            }
        }
    }
    
    return emergencyContacts
}

// Get descriptions for BRS About View
public func getAboutSections() -> [AboutSection] {
    let aboutSectionsURLString = "\(Constants.brsStackBaseURL)brs-about-sections.json"
    var aboutSections = [AboutSection]()
    
    if let url = URL(string: aboutSectionsURLString) {
        if let data = try? Data(contentsOf: url) {
            let json = JSON(data: data)
            
            for section in json["sections"].arrayValue {
                let title = section["title"].stringValue
                let summary = section["summary"].stringValue
                let link = section["link"].stringValue
                
                aboutSections.append(AboutSection(title: title, summary: summary, link: link))
            }
        }
    }
    
    return aboutSections
}

// MARK: - Date and Time Methods

// Get the current day of the week in int format
public func getDayOfWeek(today: Date) -> Int {
    return Calendar(identifier: .gregorian).component(.weekday, from: today)
}

// Creates time from JSON string, where time string must have format H:mm a
public func getTime(time: String) -> (Int, Int) {
    var hourArr = time.components(separatedBy: ":") // ["h","mm a"]
    let minArr = hourArr[1].components(separatedBy: " ") // ["mm","a"]
    let timeArr = [hourArr[0]] + minArr // ["h","mm","a"]
    
    let minute = Int(timeArr[1])!
    let hour12 = Int(hourArr[0])!
    
    var hour = 0
    let aa = timeArr[2].lowercased()
    if aa=="am" && hour12 == 12 { // 12:xx am = 0:xx
        hour = 0
    } else if aa=="pm" && hour12 != 12 { // 12:xx pm = 12:xx
        hour = hour12 + 12 // h:xx pm = (h+12):xx
    } else {
        hour = hour12
    }
    
    return (hour, minute)
}
