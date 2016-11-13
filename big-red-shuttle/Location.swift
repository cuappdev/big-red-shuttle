import UIKit
import CoreLocation

@objc class Coordinate: NSObject {
    
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    
    init(latitude: Double, longitude: Double, timestamp: Date) {
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
    }
    
    init(location: CLLocationCoordinate2D, timestamp: Date) {
        latitude = location.latitude
        longitude = location.longitude
        self.timestamp = timestamp
    }
}

class Location: NSObject, CLLocationManagerDelegate {
    
    static let sharedLocation = Location()
    let locationManager = CLLocationManager()
    var currentUserLocation: Coordinate?
    var currentBusLocation: Coordinate?
    
    override init() {
        super.init()
        
        // Ask for Authorization from the User.
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location?.coordinate {
            print("longitude: \(location.longitude), latitude: \(location.latitude)")
            currentUserLocation = Coordinate(location: location, timestamp: Date())
        }
    }

}
