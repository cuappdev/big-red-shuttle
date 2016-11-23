import UIKit

extension UIViewController {

    static func topViewController() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            // topController should now be your topmost view controller
            return topController
        }
        
        return nil
    }
    
}
