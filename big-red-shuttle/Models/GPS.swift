import UIKit
import SwiftyJSON

@objc protocol ShuttleBusGPSDelegate: class {
    
    @objc optional func gps(gps: GPS, movedToCoordinate coordinate: Coordinate)
    @objc optional func gpsStartedFetching(gps: GPS)
    @objc optional func gpsStoppedFetching(gps: GPS)
    @objc optional func gpsStartedLogging(gps: GPS)
    @objc optional func gpsStoppedLogging(gps: GPS)
    
}

@objc class GPS: NSObject {
    
    static let shared = GPS()
    var observers = [ShuttleBusGPSDelegate?]()
    var fetchUpdateFrequency: Double = 5.0
    var logUpdateFrequency: Double = 5.0
    var registeredToLogLocation = false
    var isFetchingShuttleLocation = false
    var isLoggingShuttleLocation = false
    var currentBusLocation: Coordinate?
    
    override init() {
        super.init()
    }
    
    func addObserver(observer: ShuttleBusGPSDelegate) {
        weak var weakObserver = observer
        observers.append(weakObserver)
    }
    
    func removeObserver(observer: ShuttleBusGPSDelegate) {
        weak var weakObserver = observer
        for i in 0..<observers.count {
            if weakObserver === observers[i] {
                observers.remove(at: i)
                return
            }
        }
    }
    
    // MARK: - Logging
    
    func startLoggingShuttleLocation() {
        if !isLoggingShuttleLocation {
            isLoggingShuttleLocation = true
            notifyObserversGPSBeganLogging()
            logShuttleLocation()
        }
    }
    
    func stopLoggingShuttleLocation() {
        if isLoggingShuttleLocation {
            isLoggingShuttleLocation = false
            notifyObserversGPSStoppedLogging()
        }
    }
    
    @objc func logShuttleLocation() {
        if !isLoggingShuttleLocation { return }
        
        API.shared.logLocation(success: { (json: JSON?) in
            Timer.scheduledTimer(timeInterval: self.logUpdateFrequency,
                                 target: self,
                                 selector: #selector(self.logShuttleLocation),
                                 userInfo: nil,
                                 repeats: false)
        }, failure: { (json: JSON?) in
            self.stopLoggingShuttleLocation()
        })
    }
    
    // MARK: - Fetching

    func startFetchingShuttleLocation() {
        if !isFetchingShuttleLocation {
            isFetchingShuttleLocation = true
            notifyObserversGPSBeganFetching()
            fetchShuttleLocation()
        }
    }
    
    func stopFetchingShuttleLocation() {
        if isFetchingShuttleLocation {
            isFetchingShuttleLocation = false
            notifyObserversGPSStoppedFetching()
        }
    }
    
    @objc func fetchShuttleLocation() {
        if !isFetchingShuttleLocation { return }
        
        API.shared.getLocation(success: { (json: JSON?) in
            if let coordinate = self.currentBusLocation {
                self.notifyObserversGPSMovedToCoordinate(coordinate: coordinate)
                Timer.scheduledTimer(timeInterval: self.fetchUpdateFrequency,
                                     target: self,
                                     selector: #selector(self.fetchShuttleLocation),
                                     userInfo: nil,
                                     repeats: false)
                
            } else {
                self.stopFetchingShuttleLocation()
            }
        }, failure: { (json: JSON?) in
            self.stopFetchingShuttleLocation()
        })
        
    }
    
    // MARK: - Notify Observers
    
    func notifyObserversGPSMovedToCoordinate(coordinate: Coordinate) {
        let _ = self.observers.map({ $0?.gps?(gps: self, movedToCoordinate: coordinate) })
    }
    
    func notifyObserversGPSBeganLogging() {
        let _ = self.observers.map({ $0?.gpsStartedLogging?(gps: self) })
    }
    
    func notifyObserversGPSStoppedLogging() {
        let _ = self.observers.map({ $0?.gpsStoppedLogging?(gps: self) })
    }
    
    func notifyObserversGPSBeganFetching() {
        let _ = self.observers.map({ $0?.gpsStartedFetching?(gps: self) })
    }
    
    func notifyObserversGPSStoppedFetching() {
        let _ = self.observers.map({ $0?.gpsStoppedFetching?(gps: self) })
    }

}
