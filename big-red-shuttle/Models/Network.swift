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
    
    // Register a user to log location using an authentication key
    func registerUserToLogLocation(key: String, success: ((JSON?) -> ())?, failure: ((JSON?) -> ())?) {
        
        guard let uid = system().uid() else {
            showErrorAlert(title: "Error", message: "Could not get user id")
            failure?(nil)
            return
        }
        
        let parameters = ["uid": uid, "key": key]
        
        request(endpoint: "/register", parameters: parameters, method: .post, encoding: JSONEncoding.default, success: success, failure: failure)
    }
    
    // Log the location of the shuttle
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
    
    // Fetch the last logged location of the shuttle
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
                if let timestamp = DateFormatter.longDateTimeFormatter.date(from: date) {
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
