import UIKit
import CoreLocation

class Coordinate {
    
    let latitude: Double
    let longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(location: CLLocationCoordinate2D) {
        latitude = location.latitude
        longitude = location.longitude
    }
}

class Location: NSObject, CLLocationManagerDelegate {
    
    static let sharedLocation = Location()
    let locationManager = CLLocationManager()
    var currentUserLocation: Coordinate?
    var currentBusLocation: Coordinate?
    
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
            currentUserLocation = Coordinate(location: location)
        }
    }

}
