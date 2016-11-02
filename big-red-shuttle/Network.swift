import Alamofire
import SwiftyJSON
import CoreLocation

func system() -> System {
    return System.sharedSystem
}

func api() -> API {
    return API.sharedAPI
}

class System {
    
    static let sharedSystem = System()
    
    func uid() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    func authenticationKey() -> String? {
        return UserDefaults.standard.string(forKey: "authenticationKey")
    }
    
    func userLocation() -> Coordinate? {
       return Location.sharedLocation.currentUserLocation
    }

    func busLocation() -> Coordinate? {
        return Location.sharedLocation.currentBusLocation
    }
}

class API {
    
    static let sharedAPI = API()
    let baseURLString = "..."
    
    /// registers a user to log location using an authentication key
    func registerUserToLogLocation(uid: String, key: String, completion: (() -> ())?) {
        
        let parameters = ["uid": uid, "key": key]
        
        request(parameters: parameters) { (response: JSON) in
            completion?()
        }
    }
    
    /// logs the location of the shuttle
    func logLocation(uid: String, longitude: String, latitude: String) {
        
        guard let userLocation = system().userLocation() else {
            showErrorAlert(title: "Error", message: "Could not get user location")
            return
        }
        
        let parameters = ["uid": uid, "longitude": "\(userLocation.longitude)", "latitude": "\(userLocation.latitude)"]
        
        request(parameters: parameters, completion: nil)
    }
    
    /// fetches the last logged location of the shuttle
    func getLocation(uid: String, completion: ((Coordinate) -> ())?) {
        
        let parameters = ["uid": uid]
        
        request(parameters: parameters) { (response: JSON) in
            let latitude = CLLocationDegrees(response["latitude"].floatValue)
            let longitude = CLLocationDegrees(response["longitude"].floatValue)
            let coordinate = Coordinate(latitude: latitude, longitude: longitude)
            
            Location.sharedLocation.currentBusLocation = coordinate
            completion?(coordinate)
        }
    }
    
    func request(parameters: [String: Any], completion: ((JSON) -> ())?) {
        
        Alamofire.request(baseURLString, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: [:]).responseData { (response: DataResponse<Data>) in
            
            switch response.result {
                
            case .success(let data):
                let responseJSON = JSON(data: data)
                completion?(responseJSON)
                
            case .failure(let error):
                if let url = response.response?.url?.absoluteURL {
                    print(url)
                }
                print(error.localizedDescription)
                
                guard let responseData = response.data else {
                    return
                }
                let errorJSON = JSON(responseData)
                
                //TODO log error with an alert
            }
            
        }
    }
    
    func showErrorAlert(title: String, message: String) {
        if let topViewController = UIViewController.topViewController() {
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            topViewController.present(alertController, animated: true, completion: nil)
        }
    }
}


public func getStops() ->  [Stop] {
    let stopJsonString = "https://raw.githubusercontent.com/cuappdev/big-red-shuttle-stack/master/big-red-shuttle.json"
    var stops = [Stop]()
    if let url = URL(string: stopJsonString) {
        if let data = try? Data(contentsOf: url) {
            let json = JSON(data: data)
            for stop in json["stops"].arrayValue {
                var dayArray = [Days]()
                let name = stop["name"].stringValue
                let lat = stop["lat"].floatValue
                let long = stop["long"].floatValue
                let days = stop["days"].arrayObject!
                
                for day in days {
                    dayArray.append(Days(rawValue: day as! String)!)
                }
                
                let timeStrings = stop["times"].arrayObject! as! [String]
                var times:[Time] = []
                for tStr in timeStrings {
                    times.append(getTime(time: tStr))
                }
                times = times.sorted(by: timeCompare)
                stops.append(Stop(name: name, lat: lat, long: long, days: dayArray, times: times))
  
            }
        }
    }
    return stops

}

/* Creates time from JSON string
 * Time string must have format:
 * H:mm a
 */
public func getTime(time: String) -> Time{
    var hourArr = time.components(separatedBy: ":") //["h","mm a"]
    let minArr = hourArr[1].components(separatedBy: " ") //["mm","a"]
    let timeArr = [hourArr[0]] + minArr //["h","mm","a"]
    
    let minute = Int(timeArr[1])!
    
    let hour12 = Int(hourArr[0])!
    
    var hour = 0
    let aa = timeArr[2].lowercased()
    if(aa=="am" && hour12 == 12){ //12:xx am = 0:xx
        hour = 0
    }else if(aa=="pm" && hour12 != 12){ //12:xx pm = 12:xx
        hour = hour12 + 12 //h:xx pm = (h+12):xx
    }else{
        hour = hour12
    }
    
    return Time(hour: hour, minute: minute)
}
