import UIKit
import SwiftyJSON

@objc protocol ShuttleBusGPSDelegate: class {
    
    @objc optional func gps(gps: GPS, movedToCoordinate coordinate: Coordinate)
    @objc optional func gpsBeganFetching(gps: GPS)
    @objc optional func gpsStoppedFetching(gps: GPS)
    @objc optional func gpsBeganLogging(gps: GPS)
    @objc optional func gpsStoppedLogging(gps: GPS)
    
}

@objc class GPS: NSObject {
    
    static let shared = GPS()
    var observers = [ShuttleBusGPSDelegate?]()
    var fetchUpdateFrequency: Double = 5.0
    var logUpdateFrequency: Double = 5.0
    var isFetchingShuttleLocation = false
    var isLoggingShuttleLocation = false
    
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
    
    //MARK: - Logging
    
    func beginLoggingShuttleLocation() {
        isLoggingShuttleLocation = true
        notifyObserversGPSBeganLogging()
        logShuttleLocation()
    }
    
    func stopLoggingShuttleLocation() {
        isLoggingShuttleLocation = false
        notifyObserversGPSStoppedLogging()
    }
    
    func logShuttleLocation() {
        if !isLoggingShuttleLocation { return }
        
        api().logLocation(success: { (json: JSON?) in
            Timer.scheduledTimer(timeInterval: self.fetchUpdateFrequency,
                                 target: self,
                                 selector: #selector(self.fetchShuttleLocation),
                                 userInfo: nil,
                                 repeats: false)
        }, failure: { (json: JSON?) in
            self.stopLoggingShuttleLocation()
        })
    }
    
    //MARK: - Fetching

    func beginFetchingShuttleLocation() {
        isFetchingShuttleLocation = true
        notifyObserversGPSBeganFetching()
        fetchShuttleLocation()
    }
    
    func stopFetchingShuttleLocation() {
        isFetchingShuttleLocation = false
        notifyObserversGPSStoppedFetching()
    }
    
    @objc func fetchShuttleLocation() {
        if !isFetchingShuttleLocation { return }
        
        api().getLocation(success: { (json: JSON?) in
            if let coordinate = system().busLocation() {
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
    
    //MARK: - Nofify Observers
    
    func notifyObserversGPSMovedToCoordinate(coordinate: Coordinate) {
        let _ = self.observers.map({ $0?.gps?(gps: self, movedToCoordinate: coordinate) })
    }
    
    func notifyObserversGPSBeganLogging() {
        let _ = self.observers.map({ $0?.gpsBeganLogging?(gps: self) })
    }
    
    func notifyObserversGPSStoppedLogging() {
        let _ = self.observers.map({ $0?.gpsStoppedLogging?(gps: self) })
    }
    
    func notifyObserversGPSBeganFetching() {
        let _ = self.observers.map({ $0?.gpsBeganFetching?(gps: self) })
    }
    
    func notifyObserversGPSStoppedFetching() {
        let _ = self.observers.map({ $0?.gpsStoppedFetching?(gps: self) })
    }

}
