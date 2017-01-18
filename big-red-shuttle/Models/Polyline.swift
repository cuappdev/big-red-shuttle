//
//  Polyline.swift
//  big-red-shuttle
//
//  Created by Annie Cheng on 11/21/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import Foundation
import SwiftyJSON

class Polyline: NSObject {
    var overviewPolyline = ""
    
    enum Status: String {
        case OK = "OK"
        case ZERO_RESULTS = "ZERO_RESULTS"
        case OVER_QUERY_LIMIT = "OVER_QUERY_LIMIT"
        case REQUEST_DENIED = "REQUEST_DENIED"
        case INVALID_REQUEST = "INVALID_REQUEST"
        case UNKNOWN_ERROR = "UNKNOWN_ERROR"
    }
    
    func getPolyline(waypoints: [Stop], origin: Stop, end: Stop) {
        let baseDirectionsURL = "https://maps.googleapis.com/maps/api/directions/json?"
        let origin = "\(origin.lat),\(origin.long)"
        let destination = "\(end.lat),\(end.long)"
        
        var directionsURLString = baseDirectionsURL + "origin=" + origin + "&destination=" + destination
        
        if waypoints.count > 0 {
            directionsURLString += "&waypoints=optimize:false"
            for waypoint in waypoints {
                let coords = "\(waypoint.lat),\(waypoint.long)"
                directionsURLString +=  "|\(coords)"
            }
        }
        
        directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        if let directionsURL = URL(string: directionsURLString) {
            if let data = try? Data(contentsOf: directionsURL) {
                let json = JSON(data: data)
                let status = Status(rawValue: json["status"].stringValue)!
                
                switch status {
                case .OK:
                    overviewPolyline = json["routes"][0]["overview_polyline"]["points"].stringValue
                case .ZERO_RESULTS:
                    print("zero results, can't draw shuttle routes")
                case .OVER_QUERY_LIMIT:
                    print("over query limit, can't draw shuttle routes")
                case .REQUEST_DENIED:
                    print("request was denied, can't draw shuttle routes")
                case .INVALID_REQUEST:
                    print("invalid request, can't draw shuttle routes")
                case .UNKNOWN_ERROR:
                    print("unknown, can't draw shuttle routes")
                }
            }
        }
    }
}
