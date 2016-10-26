//
//  LocationManager.swift
//  big-red-shuttle
//
//  Created by Dennis Fedorko on 10/26/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import UIKit
import CoreLocation

class Location: NSObject, CLLocationManagerDelegate {
    
    static let sharedLocation = Location()
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        // Ask for Authorisation from the User.
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location?.coordinate {
            print("longitude: \(location.longitude), latitude: \(location.latitude)")
        }
    }

}
