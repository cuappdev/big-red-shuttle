import Alamofire
import SwiftyJSON
import CoreLocation

func system() -> System {
    return System.shared
}

class System {
    
    static let shared = System()
    
    func uid() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    func authenticationKey() -> String? {
        return UserDefaults.standard.string(forKey: "authenticationKey")
    }
}

class API {
    
    static let shared = API()
    let baseURLString = "https://big-red-shuttle.herokuapp.com"
    
    /// registers a user to log location using an authentication key
    func registerUserToLogLocation(key: String, success: ((JSON?) -> ())?, failure: ((JSON?) -> ())?) {
        
        guard let uid = system().uid() else {
            showErrorAlert(title: "Error", message: "Could not get user id")
            failure?(nil)
            return
        }
        
        let parameters = ["uid": uid, "key": key]
        
        request(endpoint: "/register", parameters: parameters, method: .post, encoding: JSONEncoding.default, success: success, failure: failure)
    }
    
    /// logs the location of the shuttle
    func logLocation(success: ((JSON?) -> ())?, failure: ((JSON?) -> ())?) {
        
        guard let uid = system().uid() else {
            showErrorAlert(title: "Error", message: "Could not get user id")
            failure?(nil)
            return
        }

        guard let userLocation = Location.shared.currentUserLocation else {
            showErrorAlert(title: "Error", message: "Could not get user location")
            failure?(nil)
            return
        }
        
        let parameters = ["uid": uid, "latitude": "\(userLocation.latitude)", "longitude": "\(userLocation.longitude)"]
        
        request(endpoint: "/log", parameters: parameters, method: .post, encoding: JSONEncoding.default, success: success, failure: failure)
    }
    
    /// fetches the last logged location of the shuttle
    func getLocation(success: ((JSON?) -> ())?, failure: ((JSON?) -> ())?) {
        
        guard let uid = system().uid() else {
            showErrorAlert(title: "Error", message: "Could not get user id")
            return
        }
        
        let parameters = ["uid": uid]
        
        request(endpoint: "/latest", parameters: parameters, method: .get, encoding: URLEncoding.default, success: { (json: JSON?) in
        
            guard let response = json else {
                failure?(nil)
                return
            }
            
            if let latitude = response["latitude"].double,
            let longitude = response["longitude"].double,
            let date = response["date"].string {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
                
                if let timestamp = dateFormatter.date(from: date) {
                    let coordinate = Coordinate(latitude: latitude, longitude: longitude, timestamp: timestamp)
                    GPS.shared.currentBusLocation = coordinate
                }
            }
        
            success?(response)
            
        }, failure: failure)
    }
    
    func request(endpoint: String, parameters: [String: Any], method: HTTPMethod, encoding: ParameterEncoding, success: ((JSON?) -> ())?, failure: ((JSON?) -> ())?) {
        
        let headers = ["Content-Type":"application/json"]
        
        Alamofire.request(baseURLString + endpoint, method: method, parameters: parameters, encoding: encoding, headers: headers).responseData { (response: DataResponse<Data>) in
            
            switch response.result {
                
            case .success(let data):
                let responseJSON = JSON(data: data)
                
                if responseJSON["result"].stringValue == "success" {
                     success?(responseJSON)
                } else {
                    self.showErrorAlert(title: "Error", message: responseJSON["result"].stringValue)
                }
                
            case .failure(let error):
                if let url = response.response?.url?.absoluteURL {
                    print(url)
                }
                print(error.localizedDescription)
                
                guard let responseData = response.data else {
                    return
                }
                let errorJSON = JSON(responseData)
                failure?(errorJSON)
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
    
    func getPolyline(waypoints:[Stop], origin:Stop, end:Stop) {
        let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
        let origin = "\(origin.lat),\(origin.long)"
        let destination = "\(end.lat),\(end.long)"
        
        var directionsURLString = baseURLDirections + "origin=" + origin + "&destination=" + destination
        
        if waypoints.count > 0 {
            directionsURLString += "&waypoints=optimize:true"
            for i in 0..<waypoints.count {
                let coords = "\(waypoints[i].lat),\(waypoints[i].long)"
                directionsURLString +=  "|" + coords
            }
        }
        
        directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print(directionsURLString)
        if let directionsURL = URL(string: directionsURLString) {
            if let data = try? Data(contentsOf: directionsURL) {
                let json = JSON(data: data)
                let status = Status(rawValue: json["status"].stringValue)!
                
                switch status {
                    case .OK:
                        overviewPolyline = json["routes"][0]["overview_polyline"]["points"].stringValue
                    case .ZERO_RESULTS:
                        print("zero results, can't draw bus routes")
                    case .OVER_QUERY_LIMIT:
                        print("over query limit, can't draw bus routes")
                    case .REQUEST_DENIED:
                        print("request was denied, can't draw bus routes")
                    case .INVALID_REQUEST:
                        print("invalid request, can't draw bus routes")
                    case .UNKNOWN_ERROR:
                        print("unknown, can't draw bus routes")
                }
            }
        }
    }
}


/* Creates time from JSON string
 * Time string must have format:
 * H:mm a
 */
public func getTime(time: String) -> (Int, Int) {
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

    return (hour, minute)
}
