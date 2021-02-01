//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Anan Yousef on 27/01/2021.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dataController = DataController(modelName:"VirtualTourist")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        dataController.load()
        
        let navVC = window?.rootViewController as! UINavigationController
        let mapVC = navVC.topViewController as! MapVC
        mapVC.dataController = dataController
        return true
    }

}

