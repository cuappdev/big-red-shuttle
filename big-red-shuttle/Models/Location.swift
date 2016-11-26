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
    
    func asCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

class Location: NSObject, CLLocationManagerDelegate {
    
    static let shared = Location()
    let locationManager = CLLocationManager()
    var currentUserLocation: Coordinate?
    var fetchedUserLocationCompletionBlock: (() -> ())?
    
    override init() {
        super.init()
        
        // Ask for Authorization from the User
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
        
        fetchedUserLocationCompletionBlock?()
        fetchedUserLocationCompletionBlock = nil
    }

}
