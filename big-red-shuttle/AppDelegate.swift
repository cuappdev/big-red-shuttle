//
//  AppDelegate.swift
//  big-red-shuttle
//
//  Created by Kevin Greer on 10/12/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON

enum FileReadingError : Error { case fileNotFound }

struct Color{
    static var red = UIColor(red:0.84, green:0.29, blue:0.21, alpha:1.0)
    static var black = UIColor(red:0.35, green:0.35, blue:0.45, alpha:1.0)
    static var greyedout = UIColor(red:0.56, green:0.58, blue:0.63, alpha:1.0)
    static var lightgrey = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.0)

}

extension UINavigationController{
    
    override open func viewDidLoad() {
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Color.black, NSFontAttributeName: UIFont(name: "HelveticaNeue-Medium" , size: 18.0)!]
        self.navigationBar.barTintColor = Color.lightgrey
        self.navigationBar.isTranslucent = false
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let json = try! JSON(data: Data(contentsOf: Bundle.main.url(forResource: "config", withExtension: "json")!))
        GMSServices.provideAPIKey(json["google-maps"].stringValue)
        
        //Set up tab bar & VCs
        let tabBarController = UITabBarController()
        
        let navigationVC = StopsViewController() //fill in w/ actual VCs
        let scheduleVC = UINavigationController(rootViewController: ScheduleViewController())
        let emergencyVC = UINavigationController(rootViewController: StopsViewController())
        
        let navigationIcon = UITabBarItem(title: "Navigation", image: UIImage(named: "navigation"), tag: 0)
        let scheduleIcon = UITabBarItem(title: "Schedule", image: UIImage(named: "schedule"), tag: 0)
        let emergencyIcon = UITabBarItem(title: "Emergency", image: UIImage(named: "emergency"), tag: 0)
        
        navigationVC.tabBarItem = navigationIcon
        scheduleVC.tabBarItem = scheduleIcon
        emergencyVC.tabBarItem = emergencyIcon
        
        tabBarController.viewControllers = [navigationVC,scheduleVC,emergencyVC]
        tabBarController.selectedViewController = scheduleVC
        tabBarController.tabBar.tintColor = Color.red
            //get rid of top line of tab bar
        tabBarController.tabBar.clipsToBounds = true
        
        //Set up window
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.makeKeyAndVisible()
        window?.rootViewController = tabBarController
        
        //Light status bar
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

